{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
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
    withLndTestT,
    setGrpcCtxT,
  )
where

import BtcLsp.Data.Env as Env
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Import as I hiding (setGrpcCtxT)
import qualified BtcLsp.Import.Psql as Psql
import BtcLsp.Rpc.Env
import qualified BtcLsp.Storage.Model.LnChan as LnChan (getByChannelPoint)
import Data.Aeson (eitherDecodeStrict)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8 hiding (filter, length)
import Data.ProtoLens.Field
import qualified Env as E
import LndClient (LndEnv (..))
import qualified LndClient as Lnd
import qualified LndClient.Data.GetInfo as GetInfo
import qualified LndClient.Data.SignMessage as Lnd
import LndClient.LndTest as ReExport (LndTest)
import qualified LndClient.LndTest as LndTest
import qualified LndClient.RPC.Katip as Lnd
import Network.Bitcoin as Btc (Client, getClient)
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import Test.Hspec
import Prelude (show)

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
    testEnvBtc :: Btc.Client,
    testEnvLndLsp :: LndTest.TestEnv,
    testEnvLndAlice :: LndTest.TestEnv,
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
    asks $ envGrpcServer . testEnvLsp
  getSwapIntoLnMinAmt =
    asks $ envSwapIntoLnMinAmt . testEnvLsp
  getMsatPerByte =
    asks $ envMsatPerByte . testEnvLsp
  getLspPubKeyVar =
    asks $ envLndPubKey . testEnvLsp
  getLspLndEnv =
    asks $ envLnd . testEnvLsp
  getChanPrivacy =
    asks $ envChanPrivacy . testEnvLsp
  getLndP2PSocketAddress = do
    host <- asks $ envLndP2PHost . testEnvLsp
    port <- asks $ envLndP2PPort . testEnvLsp
    pure
      SocketAddress
        { socketAddressHost = host,
          socketAddressPort = port
        }
  withLnd method args = do
    lnd <- asks $ envLnd . testEnvLsp
    first FailureLnd <$> args (method lnd)
  withElectrs method args =
    maybeM
      (error "Electrs Env is missing")
      ((first FailureElectrs <$>) . args . method)
      . asks
      $ envElectrs . testEnvLsp
  withBtc method args = do
    env <- asks $ Env.envBtc . testEnvLsp
    --
    -- TODO : catch exceptions!!!
    --
    liftIO $ Right <$> args (method env)

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

withLndTestT ::
  ( LndTest m owner
  ) =>
  owner ->
  (Lnd.LndEnv -> a) ->
  (a -> m (Either Lnd.LndError b)) ->
  ExceptT Failure m b
withLndTestT owner method args = do
  env <- lift $ LndTest.getLndEnv owner
  ExceptT $ first FailureLnd <$> args (method env)

withTestEnv' :: (TestEnv owner -> IO ()) -> IO ()
withTestEnv' action = do
  gcEnv <- readGCEnv
  lspRc <- readRawConfig
  lndAliceEnv <- readLndAliceEnv
  btcClient <-
    Btc.getClient
      (unpack . bitcoindEnvHost $ rawConfigBtcEnv lspRc)
      (encodeUtf8 . bitcoindEnvUsername $ rawConfigBtcEnv lspRc)
      (encodeUtf8 . bitcoindEnvPassword $ rawConfigBtcEnv lspRc)
  let aliceRc =
        lspRc
          { rawConfigLndEnv = lndAliceEnv
          }
  withEnv lspRc $ \lspAppEnv ->
    liftIO $
      withEnv aliceRc $ \aliceAppEnv -> do
        let katipNS = envKatipNS lspAppEnv
        let katipLE = envKatipLE lspAppEnv
        let katipCTX = envKatipCTX lspAppEnv
        runKatipContextT katipLE katipCTX katipNS $
          LndTest.withTestEnv
            (envLnd lspAppEnv)
            (Lnd.NodeLocation $ getP2PAddr (envLndP2PHost lspAppEnv) (envLndP2PPort lspAppEnv))
            $ \lspTestEnv ->
              LndTest.withTestEnv
                (envLnd aliceAppEnv)
                (Lnd.NodeLocation $ getP2PAddr (envLndP2PHost aliceAppEnv) (envLndP2PPort aliceAppEnv))
                $ \aliceTestEnv ->
                  liftIO . action $
                    TestEnv
                      { testEnvLsp = lspAppEnv,
                        testEnvBtc = btcClient,
                        testEnvLndLsp = lspTestEnv,
                        testEnvLndAlice = aliceTestEnv,
                        testEnvKatipNS = katipNS,
                        testEnvKatipLE = katipLE,
                        testEnvKatipCTX = katipCTX,
                        testEnvGCEnv =
                          gcEnv
                            { gcEnvSigner =
                                runKatipContextT
                                  katipLE
                                  katipCTX
                                  katipNS
                                  . signT
                                    ( LndTest.testLndEnv
                                        aliceTestEnv
                                    )
                            }
                      }
  where
    getP2PAddr host port = pack host <> ":" <> pack (show port)


signT ::
  Lnd.LndEnv ->
  ByteString ->
  KatipContextT IO (Maybe ByteString)
signT env msg = do
  $(logTM) DebugS . logStr $ ("=====Sign TestAppM.hs " :: Text)
  eSig <-
    Lnd.signMessage env $
      Lnd.SignMessageRequest
        { Lnd.message = msg,
          Lnd.keyLoc =
            Lnd.KeyLocator
              { Lnd.keyFamily = 6,
                Lnd.keyIndex = 0
              },
          Lnd.doubleHash = False,
          Lnd.compactSig = False
        }
  case eSig of
    Left e -> do
      $(logTM) ErrorS . logStr $
        "Client ==> signing procedure failed "
          <> inspect e
      pure Nothing
    Right sig0 -> do
      let sig = coerce sig0
      $(logTM) DebugS . logStr $
        "Client ==> signing procedure succeeded for msg of "
          <> inspect (BS.length msg)
          <> " bytes "
          <> inspect msg
          <> " got signature of "
          <> inspect (BS.length sig)
          <> " bytes "
          <> inspect sig
      pure $ Just sig

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

readLndAliceEnv :: IO LndEnv
readLndAliceEnv =
  E.parse
    (E.header "LndEnv")
    $ E.var
      (parser <=< E.nonempty)
      "LND_ALICE_ENV"
      (E.keep <> E.help "")
  where
    parser :: String -> Either E.Error LndEnv
    parser x =
      first E.UnreadError $ eitherDecodeStrict $ C8.pack x

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

setGrpcCtxT ::
  ( HasField msg "ctx" Proto.Ctx,
    MonadUnliftIO m,
    LndTest m owner
  ) =>
  owner ->
  msg ->
  ExceptT Failure m msg
setGrpcCtxT owner message = do
  nonce <- newNonce
  pubKey <-
    GetInfo.identityPubkey
      <$> withLndTestT owner Lnd.getInfo id
  pure $
    message
      & field @"ctx"
        .~ ( defMessage
               & Proto.nonce
                 .~ from @Nonce @Proto.Nonce nonce
               & Proto.lnPubKey
                 .~ from @Lnd.NodePubKey @Proto.LnPubKey pubKey
           )
