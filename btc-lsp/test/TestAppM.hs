{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module TestAppM
  ( runTestApp,
    TestAppM,
    TestEnv (..),
    TestOwner (..),
    proxyOwner,
    assertChannelState,
    module ReExport,
    itProp,
    itEnv,
    itMain,
    itEnvT,
    itMainT,
    withTestEnv,
    getGCEnv,
    withLndTestT,
    getPubKeyT,
    setGrpcCtxT,
    forkThread,
    mainTestSetup,
  )
where

import BtcLsp.Data.Env as Env
import BtcLsp.Grpc.Client.LowLevel
import qualified BtcLsp.Grpc.Sig as Sig
import BtcLsp.Import as I hiding (setGrpcCtxT)
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Migration as Migration
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified BtcLsp.Thread.Main as Main
import Data.Aeson (eitherDecodeStrict)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8 hiding (filter, length)
import Data.List.Extra as Import (enumerate)
import Data.ProtoLens.Field
import qualified Env as E
import LndClient (LndEnv (..))
import qualified LndClient as Lnd
import qualified LndClient.Data.GetInfo as GetInfo
import qualified LndClient.Data.SignMessage as Lnd
import qualified LndClient.Data.WalletBalance as Lnd
import LndClient.LndTest as ReExport (LndTest)
import qualified LndClient.LndTest as LndTest
import qualified LndClient.RPC.Silent as Lnd
import Network.Bitcoin as Btc (Client, getClient)
import qualified Network.Bitcoin as Btc
import Network.Bitcoin.BtcMultiEnv (BtcMultiEnv)
import qualified Network.Bitcoin.BtcMultiEnv
import qualified Network.Bitcoin.BtcMultiEnv as BtcMultiEnv
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import Test.Hspec
import Test.QuickCheck
import UnliftIO.Concurrent (ThreadId, forkFinally)
import Prelude (show)

data TestOwner
  = LndLsp
  | LndAlice
  deriving stock
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
    testEnvBtc2 :: Btc.Client,
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
  deriving stock (Functor)
  deriving newtype
    ( Applicative,
      Monad,
      MonadIO,
      MonadReader (TestEnv owner),
      MonadUnliftIO
    )

runTestApp :: TestEnv owner -> TestAppM owner m a -> m a
runTestApp env app =
  runReaderT (unTestAppM app) env

instance (MonadUnliftIO m) => BtcEnv (TestAppM 'LndLsp m) Failure where
  getBtcCfg = asks $ envBtcCfg . testEnvLsp
  getBtcClient = asks $ envBtc . testEnvLsp
  handleBtcFailure = handleBtcFailureGen

instance (MonadUnliftIO m) => BtcMultiEnv (TestAppM owner m) Failure TestOwner where
  getBtcCfg =
    --
    -- NOTE : getBtcCfg is just a placeholder here,
    -- not used really, so details do not matter much.
    --
    const . asks $
      envBtcCfg . testEnvLsp
  getBtcClient owner =
    asks $
      case owner of
        LndLsp -> testEnvBtc
        LndAlice -> testEnvBtc2
  handleBtcFailure =
    const handleBtcFailureGen

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
  getYesodLog =
    asks $ envYesodLog . testEnvLsp
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
    first (const $ FailureInt FailureRedacted) <$> args (method lnd)
  monitorTotalExtOutgoingLiquidity amt = do
    lim <- asks $ envMinTotalExtOutgoingLiquidity . testEnvLsp
    when (amt < lim) $
      $(logTM) CriticalS . logStr $
        "Not enough outgoing liquidity to the external "
          <> "lightning network, got "
          <> inspect amt
          <> " but minimum is "
          <> inspect lim
          <> "."
  monitorTotalExtIncomingLiquidity amt = do
    lim <- asks $ envMinTotalExtIncomingLiquidity . testEnvLsp
    when (amt < lim) $
      $(logTM) CriticalS . logStr $
        "Not enough incoming liquidity from the external "
          <> "lightning network, got "
          <> inspect amt
          <> " but minimum is "
          <> inspect lim
          <> "."
  monitorTotalOnChainLiquidity wal = do
    lim <- asks $ envMinTotalOnChainLiquidity . testEnvLsp
    when (Lnd.totalBalance wal < lim) $
      $(logTM) CriticalS . logStr $
        "Not enough onchain liquidity, got "
          <> inspect wal
          <> " but minimum is "
          <> inspect lim
          <> "."

instance (MonadUnliftIO m) => Katip (TestAppM owner m) where
  getLogEnv =
    asks testEnvKatipLE
  localLogEnv f (TestAppM m) =
    TestAppM
      ( local
          (\s -> s {testEnvKatipLE = f (testEnvKatipLE s)})
          m
      )

instance (MonadUnliftIO m) => KatipContext (TestAppM owner m) where
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

withTestEnv ::
  ( MonadUnliftIO m,
    BtcMultiEnv (TestAppM owner m) Failure TestOwner
  ) =>
  TestAppM owner m a ->
  m a
withTestEnv action =
  withTestEnv' $ \env ->
    runTestApp env $ do
      LndTest.setupZeroChannels proxyOwner
      lazyMineBitcoindCoins
      action

withLndTestT ::
  ( LndTest m owner
  ) =>
  owner ->
  (Lnd.LndEnv -> a) ->
  (a -> m (Either Lnd.LndError b)) ->
  ExceptT Failure m b
withLndTestT owner method args = do
  env <- lift $ LndTest.getLndEnv owner
  ExceptT $ first (const $ FailureInt FailureRedacted) <$> args (method env)

withTestEnv' ::
  ( MonadUnliftIO m
  ) =>
  (TestEnv owner -> m a) ->
  m a
withTestEnv' action = do
  gcEnv <- liftIO readGCEnv
  lspRc <- liftIO readRawConfig
  lndAliceEnv <- readLndAliceEnv
  btcClient <-
    liftIO $
      Btc.getClient
        (unpack . bitcoindEnvHost $ rawConfigBtcEnv lspRc)
        (encodeUtf8 . bitcoindEnvUsername $ rawConfigBtcEnv lspRc)
        (encodeUtf8 . bitcoindEnvPassword $ rawConfigBtcEnv lspRc)
  btcEnv2 <- readBtcEnv2
  btcClient2 <-
    liftIO $
      Btc.getClient
        (unpack . bitcoindEnvHost $ btcEnv2)
        (encodeUtf8 . bitcoindEnvUsername $ btcEnv2)
        (encodeUtf8 . bitcoindEnvPassword $ btcEnv2)
  let aliceRc =
        lspRc
          { rawConfigLndEnv = lndAliceEnv
          }
  withEnv lspRc $ \lspAppEnv ->
    lift . withEnv aliceRc $ \aliceAppEnv -> do
      let katipNS = envKatipNS lspAppEnv
      let katipLE = envKatipLE lspAppEnv
      let katipCTX = envKatipCTX lspAppEnv
      LndTest.withTestEnv
        (envLnd lspAppEnv)
        (Lnd.NodeLocation $ getP2PAddr (envLndP2PHost lspAppEnv) (envLndP2PPort lspAppEnv))
        $ \lspTestEnv ->
          LndTest.withTestEnv
            (envLnd aliceAppEnv)
            (Lnd.NodeLocation $ getP2PAddr (envLndP2PHost aliceAppEnv) (envLndP2PPort aliceAppEnv))
            $ \aliceTestEnv ->
              lift . action $
                TestEnv
                  { testEnvLsp = lspAppEnv,
                    testEnvBtc = btcClient,
                    testEnvBtc2 = btcClient2,
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
    getP2PAddr host port =
      pack host <> ":" <> pack (show port)

signT ::
  Lnd.LndEnv ->
  Sig.MsgToSign ->
  KatipContextT IO (Maybe Sig.LndSig)
signT env msg = do
  eSig <-
    Lnd.signMessage env $
      Lnd.SignMessageRequest
        { Lnd.message = Sig.unMsgToSign msg,
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
          <> inspect (BS.length $ Sig.unMsgToSign msg)
          <> " bytes "
          <> inspect msg
          <> " got signature of "
          <> inspect (BS.length sig)
          <> " bytes "
          <> inspect sig
      pure . Just $ Sig.LndSig sig

itProp ::
  forall owner.
  String ->
  TestAppM owner IO Property ->
  SpecWith (Arg (IO ()))
itProp testName expr =
  it testName $ do
    ioProperty
      . withTestEnv
      $ katipAddContext
        (sl "TestName" testName)
        expr

itEnv ::
  forall owner.
  String ->
  TestAppM owner IO () ->
  SpecWith (Arg (IO ()))
itEnv testName expr =
  it testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        expr

itMain ::
  forall owner.
  ( I.Env (TestAppM owner IO)
  ) =>
  String ->
  TestAppM owner IO () ->
  SpecWith (Arg (IO ()))
itMain testName expr =
  it testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        ( withSpawnLink Main.apply . const $ do
            -- Let endpoints and watchers spawn
            sleep300ms
            -- Evaluate given expression
            expr
        )

itEnvT ::
  forall owner e.
  ( Show e
  ) =>
  String ->
  ExceptT e (TestAppM owner IO) () ->
  SpecWith (Arg (IO ()))
itEnvT testName expr =
  it testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        ( do
            res <- runExceptT expr
            liftIO $ res `shouldSatisfy` isRight
        )

itMainT ::
  forall owner e.
  ( Show e,
    I.Env (TestAppM owner IO)
  ) =>
  String ->
  ExceptT e (TestAppM owner IO) () ->
  SpecWith (Arg (IO ()))
itMainT testName expr =
  it testName $
    withTestEnv $
      katipAddContext
        (sl "TestName" testName)
        ( do
            res <-
              withSpawnLink Main.apply . const . runExceptT $ do
                -- Let endpoints and watchers spawn
                sleep300ms
                -- Evaluate given expression
                expr
            liftIO $
              res `shouldSatisfy` isRight
        )

readLndAliceEnv :: (MonadUnliftIO m) => m LndEnv
readLndAliceEnv =
  liftIO
    . E.parse (E.header "LndEnv")
    $ E.var
      (parser <=< E.nonempty)
      "LND_ALICE_ENV"
      (E.keep <> E.help "")
  where
    parser :: String -> Either E.Error LndEnv
    parser x =
      first E.UnreadError $ eitherDecodeStrict $ C8.pack x

readBtcEnv2 :: (MonadUnliftIO m) => m BitcoindEnv
readBtcEnv2 =
  liftIO
    . E.parse (E.header "BitcoindEnv")
    $ E.var
      (parser <=< E.nonempty)
      "LSP_BITCOIND_ENV2"
      (E.keep <> E.help "")
  where
    parser :: String -> Either E.Error BitcoindEnv
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
  dbChannel <- runSql $ LnChan.getByChannelPointSql txid vout
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

getPubKeyT ::
  ( MonadUnliftIO m,
    LndTest m owner
  ) =>
  owner ->
  ExceptT Failure m Lnd.NodePubKey
getPubKeyT owner =
  GetInfo.identityPubkey
    <$> withLndTestT owner Lnd.getInfo id

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
  pubKey <- getPubKeyT owner
  pure $
    message
      & field @"ctx"
        .~ ( defMessage
               & Proto.nonce .~ toProto nonce
               & Proto.lnPubKey .~ toProto pubKey
           )

forkThread ::
  ( MonadUnliftIO m
  ) =>
  m () ->
  m (ThreadId, MVar ())
forkThread proc = do
  handle <- newEmptyMVar
  tid <- forkFinally proc (const $ putMVar handle ())
  return (tid, handle)

mainTestSetup :: IO ()
mainTestSetup =
  withTestEnv $ do
    runSql cleanTestDbSql
    Migration.migrateAll

cleanTestDbSql :: (MonadUnliftIO m) => Psql.SqlPersistT m ()
cleanTestDbSql =
  Psql.rawExecute
    ( "DROP SCHEMA IF EXISTS public CASCADE;"
        <> "CREATE SCHEMA public;"
        <> "GRANT ALL ON SCHEMA public TO public;"
        <> "COMMENT ON SCHEMA public IS 'standard public schema';"
    )
    []

lazyMineBitcoindCoins ::
  forall owner m.
  ( Enum owner,
    Bounded owner,
    KatipContext m,
    BtcMultiEnv m Failure owner
  ) =>
  m ()
lazyMineBitcoindCoins = do
  res <- runExceptT . forM_ (enumerate :: [owner]) $ \owner -> do
    bal <-
      BtcMultiEnv.withBtcT owner Btc.getBalance id
    when (bal < 1) . void $ do
      $logTM WarningS . logStr $
        "lazyMineBitcoindCoins ==> got "
          <> inspect bal
          <> " btc and mining additional coins"
      BtcMultiEnv.withBtcT
        owner
        Btc.generate
        $ \f -> f 105 Nothing
  whenLeft res $ \e ->
    error $ "lazyMineBitcoindCoins ==> failed " <> inspect e
