{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module TestAppM
  ( runTestApp,
    TestAppM,
    TestEnv (..),
    TestOwner (..),
    proxyOwner,
    assertChannelState,
    module ReExport,
    itEnv,
    xitEnv,
    withTestEnv,
    getGCEnv,
  )
where

import BtcLsp.Data.Env as Env
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Import as I
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.LnChan as LnChan (getByChannelPoint)
import Data.Aeson (eitherDecodeStrict)
import qualified Data.ByteString.Char8 as C8 hiding (filter, length)
import qualified Env as E
import LndClient (LndEnv (..))
import qualified LndClient as Lnd
import LndClient.LndTest as ReExport (LndTest)
import qualified LndClient.LndTest as LndTest
import Network.Bitcoin as Btc (Client, getClient)
import Test.Hspec

data TestOwner
  = LndLsp
  | LndAlice
  deriving
    ( Eq,
      Ord,
      Bounded,
      Enum,
      Show,
      Generic
    )

instance Out TestOwner

proxyOwner :: Proxy TestOwner
proxyOwner = Proxy

data TestEnv (owner :: TestOwner) = TestEnv
  { testEnvLsp :: Env.Env,
    testEnvLndLsp :: LndTest.TestEnv,
    testEnvLndAlice :: LndTest.TestEnv,
    testEnvBtc :: Btc.Client,
    testEnvKatipNS :: Namespace,
    testEnvKatipCTX :: LogContexts,
    testEnvKatipLE :: LogEnv,
    testEnvGCEnv :: GCEnv
  }

newtype TestAppM owner m a = TestAppM
  { unTestAppM :: ReaderT (TestEnv owner) m a
  }
  deriving
    ( Functor,
      Applicative,
      Monad,
      MonadIO,
      MonadReader (TestEnv owner),
      MonadUnliftIO
    )

runTestApp :: TestEnv owner -> TestAppM owner m a -> m a
runTestApp env app =
  runReaderT (unTestAppM app) env

instance (MonadUnliftIO m) => I.Env (TestAppM 'LndLsp m) where
  getGsEnv =
    asks $ envGrpcServerEnv . testEnvLsp
  getLspPubKeyVar =
    asks $ envLndPubKey . testEnvLsp
  withLnd method args = do
    lnd <- asks $ envLnd . testEnvLsp
    first FailureLnd <$> args (method lnd)

instance (MonadIO m) => Katip (TestAppM owner m) where
  getLogEnv =
    asks testEnvKatipLE
  localLogEnv f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipLE = f (testEnvKatipLE s)})
          m
      )

instance (MonadIO m) => KatipContext (TestAppM owner m) where
  getKatipContext =
    asks testEnvKatipCTX
  localKatipContext f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipCTX = f (testEnvKatipCTX s)})
          m
      )
  getKatipNamespace =
    asks testEnvKatipNS
  localKatipNamespace f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipNS = f (testEnvKatipNS s)})
          m
      )

instance (MonadUnliftIO m) => LndTest (TestAppM owner m) TestOwner where
  getBtcClient =
    const $ asks testEnvBtc
  getTestEnv = \case
    LndLsp -> asks testEnvLndLsp
    LndAlice -> asks testEnvLndAlice

instance (MonadUnliftIO m) => Storage (TestAppM owner m) where
  getSqlPool =
    envSQLPool <$> asks testEnvLsp
  runSql query = do
    pool <- getSqlPool
    Psql.runSqlPool query pool

withTestEnv :: TestAppM owner IO () -> IO ()
withTestEnv action =
  withTestEnv' $ \env ->
    runTestApp env $
      finally
        ( do
            LndTest.setupZeroChannels proxyOwner
            -- scheduleAll
            -- watchInvoices sub
            action
        )
        -- unScheduleAll
        $ pure ()

-- where
--   sub = SubscribeInvoicesRequest (Just $ Lnd.AddIndex 1) Nothing

withTestEnv' :: (TestEnv owner -> IO ()) -> IO ()
withTestEnv' action = do
  gcEnv <- readGCEnv
  aliceRc <- readRawConfig
  lndLspEnv <- readLndLspEnv
  let lspRc =
        aliceRc
          { rawConfigLndEnv = lndLspEnv
          }
  withEnv lspRc $ \lspAppEnv ->
    liftIO $
      withEnv aliceRc $ \aliceAppEnv -> do
        bc <- liftIO newBtcClient
        let katipNS = envKatipNS lspAppEnv
        let katipLE = envKatipLE lspAppEnv
        let katipCTX = envKatipCTX lspAppEnv
        runKatipContextT katipLE katipCTX katipNS $
          LndTest.withTestEnv
            (envLnd lspAppEnv)
            (Lnd.NodeLocation "localhost:9736")
            $ \lspTestEnv ->
              LndTest.withTestEnv
                (envLnd aliceAppEnv)
                (Lnd.NodeLocation "localhost:9737")
                $ \aliceTestEnv ->
                  liftIO $
                    action
                      TestEnv
                        { testEnvLsp = lspAppEnv,
                          testEnvLndLsp = lspTestEnv,
                          testEnvLndAlice = aliceTestEnv,
                          testEnvBtc = bc,
                          testEnvKatipNS = katipNS,
                          testEnvKatipLE = katipLE,
                          testEnvKatipCTX = katipCTX,
                          testEnvGCEnv = gcEnv
                        }

itEnv ::
  String ->
  TestAppM owner IO () ->
  SpecWith (Arg (IO ()))
itEnv testName expr =
  it testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        expr

xitEnv ::
  String ->
  TestAppM owner IO () ->
  SpecWith (Arg (IO ()))
xitEnv testName expr =
  xit testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        expr

readLndLspEnv :: IO LndEnv
readLndLspEnv =
  E.parse
    (E.header "LndEnv")
    $ E.var
      (parser <=< E.nonempty)
      "LND_LSP_ENV"
      (E.keep <> E.help "")
  where
    parser :: String -> Either E.Error LndEnv
    parser x =
      first E.UnreadError $ eitherDecodeStrict $ C8.pack x

newBtcClient :: IO Btc.Client
newBtcClient =
  getClient
    "http://localhost:18443"
    "developer"
    "developer"

waitForChannelStatus ::
  (I.Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  LnChanStatus ->
  Int ->
  m (Either Expectation LnChan)
waitForChannelStatus _ _ expectedStatus 0 =
  pure . Left . expectationFailure $
    "waiting for channel " <> inspectStr expectedStatus <> " tries exceeded"
waitForChannelStatus txid vout expectedStatus tries = do
  let loop = waitForChannelStatus txid vout expectedStatus (tries - 1)
  dbChannel <- LnChan.getByChannelPoint txid vout
  liftIO $ delay 1000000
  case dbChannel of
    Just db -> do
      let chModel = Psql.entityVal db
      let status = lnChanStatus chModel
      if status == expectedStatus
        then pure $ Right chModel
        else loop
    Nothing -> loop

assertChannelState ::
  (I.Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  LnChanStatus ->
  m ()
assertChannelState txid vout state = do
  dbChannelPending <- waitForChannelStatus txid vout state 30
  liftIO $ case dbChannelPending of
    Right channel -> shouldBe (lnChanStatus channel) state
    Left triesExceded -> triesExceded

getGCEnv ::
  ( Monad m
  ) =>
  TestAppM owner m GCEnv
getGCEnv =
  asks testEnvGCEnv
