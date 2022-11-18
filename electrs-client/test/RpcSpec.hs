{-# OPTIONS_GHC -Wno-orphans #-}

module RpcSpec
  ( spec,
  )
where

import ElectrsClient.Data.Env
import ElectrsClient.Helper
import ElectrsClient.Import.External
import ElectrsClient.Rpc as Rpc
import ElectrsClient.Type
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.BtcEnv as Btc
import qualified Network.Bitcoin.Wallet as Btc
import Test.Hspec
import Prelude (show)

instance Btc.BtcEnv IO RpcError where
  getBtcCfg = do
    rc <- readRawConfig
    let btcdEnv = rawConfigBtcEnv rc
    pure
      Btc.BtcCfg
        { Btc.btcCfgHost = bitcoindEnvHost btcdEnv,
          Btc.btcCfgUsername = bitcoindEnvUsername btcdEnv,
          Btc.btcCfgPassword = bitcoindEnvPassword btcdEnv,
          Btc.btcCfgAutoLoadWallet = Just Btc.defaultWalletCfg
        }
  getBtcClient =
    Btc.getBtcCfg
      >>= Btc.newBtcClient
  handleBtcFailure =
    pure . OtherError . pack . show

spec :: Spec
spec = do
  it "Version" $ do
    rc <- liftIO readRawConfig
    let env = rawConfigElectrsEnv rc
    ver <- Rpc.version env ()
    ver `shouldSatisfy` isRight
  it "Get Balance" $ do
    elecBal <- do
      rc <- liftIO readRawConfig
      let env = rawConfigElectrsEnv rc
      let btcdEnv = rawConfigBtcEnv rc
      runExceptT $ do
        addr <- Btc.withBtcT Btc.getNewAddress ($ Nothing)
        void $ Btc.withBtcT Btc.generateToAddress $ \f -> f 3 addr Nothing
        btcClient <- lift Btc.getBtcClient
        waitTillLastBlockProcessedT btcClient env 100
        ExceptT $ Rpc.getBalance env btcdEnv (Left $ OnChainAddress addr)
    elecBal `shouldSatisfy` isRight
    case elecBal of
      Right bal -> confirmed bal `shouldSatisfy` (> 0)
      Left _ -> error "Error getting balance"
