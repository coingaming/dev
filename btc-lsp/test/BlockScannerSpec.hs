{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Thread.Main as Main
import LndClient.LndTest (mine)
import qualified Network.Bitcoin.Wallet as Btc
import Test.Hspec
import qualified BtcLsp.Rpc.ElectrsRpc as Rpc
import BtcLsp.Rpc.Helper (waitTillLastBlockProcessedT)
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.RPC.Katip as Lnd

spec :: Spec
spec = do
  itEnv "Block scanner" $ do
    withSpawnLink Main.apply . const $ do
      sleep $ MicroSecondsDelay 500000
      addrResponse <-
        runExceptT $
          withLndT
            Lnd.newAddress
            ( $
                Lnd.NewAddressRequest
                  { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
                    Lnd.account = Nothing
                  }
            )

      mine 10 LndLsp
      case addrResponse of
        Left _ -> error "Error getting address from lnd"
        Right response -> do
            let trAddr = coerce response
            _r <- runExceptT $ do
              withBtcT Btc.sendToAddress (\h -> h trAddr 1 Nothing Nothing)
            mine 10 LndLsp
            sleep $ MicroSecondsDelay $ 10 * 1000000
            b <- runExceptT $ do
              _ <- waitTillLastBlockProcessedT 100
              withElectrsT Rpc.getBalance ($ Left $ OnChainAddress trAddr)
            traceShowM b
      sleep $ MicroSecondsDelay $ 2 * 1000000
      liftIO $ shouldBe True True

