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
  )
where

import BtcLsp.Data.Env as Env
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
import Network.Bitcoin as BTC (Client, getClient)
import Test.Hspec

data TestOwner
  = MerchantPartner
  | PaymentsPartner
  deriving (Eq, Ord, Bounded, Enum, Show, Generic)

instance Out TestOwner

proxyOwner :: Proxy TestOwner
proxyOwner = Proxy

data TestEnv (owner :: TestOwner) = TestEnv
  { testEnvMerchantAgent :: Env.Env,
    testEnvPaymentsAgent :: Env.Env,
    testEnvMerchantPartner :: LndTest.TestEnv,
    testEnvPaymentsPartner :: LndTest.TestEnv,
    testEnvBtc :: BTC.Client,
    testEnvKatipNS :: Namespace,
    testEnvKatipCTX :: LogContexts,
    testEnvKatipLE :: LogEnv
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
runTestApp env app = runReaderT (unTestAppM app) env

instance (MonadUnliftIO m) => I.Env (TestAppM 'MerchantPartner m) where
  getLndEnv = envLnd . testEnvMerchantAgent <$> ask
  getGsEnv = error "getGsEnv => impossible"

instance (MonadUnliftIO m) => I.Env (TestAppM 'PaymentsPartner m) where
  getLndEnv = envLnd . testEnvPaymentsAgent <$> ask
  getGsEnv = error "getGsEnv => impossible"

instance (MonadIO m) => Katip (TestAppM owner m) where
  getLogEnv = asks testEnvKatipLE
  localLogEnv f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipLE = f (testEnvKatipLE s)})
          m
      )

instance (MonadIO m) => KatipContext (TestAppM owner m) where
  getKatipContext = asks testEnvKatipCTX
  localKatipContext f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipCTX = f (testEnvKatipCTX s)})
          m
      )
  getKatipNamespace = asks testEnvKatipNS
  localKatipNamespace f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipNS = f (testEnvKatipNS s)})
          m
      )

instance (MonadUnliftIO m) => LndTest (TestAppM owner m) TestOwner where
  getBtcClient = const $ asks testEnvBtc
  getTestEnv = \case
    MerchantPartner -> asks testEnvMerchantPartner
    PaymentsPartner -> asks testEnvPaymentsPartner

instance (MonadUnliftIO m) => Storage (TestAppM owner m) where
  getSqlPool = envSQLPool <$> asks testEnvPaymentsAgent
  runSql query = do
    pool <- getSqlPool
    Psql.runSqlPool query pool

withTestEnv :: I.Env (TestAppM owner IO) => TestAppM owner IO () -> IO ()
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
  paymentsRc <- readRawConfig
  merchantLndEnv <- readMerchantLndEnv
  let merchantRc =
        paymentsRc
          { rawConfigLndEnv = merchantLndEnv
          }
  withEnv merchantRc $ \merchantAppEnv ->
    liftIO $
      withEnv paymentsRc $ \paymentsAppEnv -> do
        bc <- liftIO newBtcClient
        let katipNS = envKatipNS merchantAppEnv
        let katipLE = envKatipLE merchantAppEnv
        let katipCTX = envKatipCTX merchantAppEnv
        runKatipContextT katipLE katipCTX katipNS $
          LndTest.withTestEnv
            (envLnd merchantAppEnv)
            (Lnd.NodeLocation "localhost:9735")
            $ \merchantTestEnv ->
              LndTest.withTestEnv
                (envLnd paymentsAppEnv)
                (Lnd.NodeLocation "localhost:9734")
                $ \paymentsTestEnv ->
                  liftIO $
                    action
                      TestEnv
                        { testEnvMerchantAgent = merchantAppEnv,
                          testEnvPaymentsAgent = paymentsAppEnv,
                          testEnvMerchantPartner = merchantTestEnv,
                          testEnvPaymentsPartner = paymentsTestEnv,
                          testEnvBtc = bc,
                          testEnvKatipNS = katipNS,
                          testEnvKatipLE = katipLE,
                          testEnvKatipCTX = katipCTX
                        }

itEnv ::
  I.Env (TestAppM owner IO) =>
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
  I.Env (TestAppM owner IO) =>
  String ->
  TestAppM owner IO () ->
  SpecWith (Arg (IO ()))
xitEnv testName expr =
  xit testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        expr

readMerchantLndEnv :: IO LndEnv
readMerchantLndEnv =
  E.parse
    (E.header "LndEnv")
    $ E.var
      (parser <=< E.nonempty)
      "LSP_MERCHANT_LND_ENV"
      (E.keep <> E.help "")
  where
    parser :: String -> Either E.Error LndEnv
    parser x =
      first E.UnreadError $ eitherDecodeStrict $ C8.pack x

newBtcClient :: IO BTC.Client
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
