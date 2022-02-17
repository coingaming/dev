{-# LANGUAGE TemplateHaskell #-}

module RpcSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ScriptHashRpc as Rpc
import LndClient.Data.NewAddress (NewAddressResponse (NewAddressResponse))
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (getBtcClient)
import qualified LndClient.RPC.Katip as Lnd
import Network.Bitcoin.Mining (generateToAddress)
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  itEnv "Version" $ do
    ver <- withElectrs Rpc.version ($ ())
    liftIO $ ver `shouldSatisfy` isRight
  itEnv "Get Balance" $ do
    client <- getBtcClient LndLsp
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
    case addrResponse of
      Left _ -> error "Error getting address from lnd"
      Right response -> do
        let addr = coerce response
        _ <- liftIO $ generateToAddress client 3 addr Nothing

        --Sleep ten seconds to electrs synchronize with blockchain
        sleep $ MicroSecondsDelay 10000000
        elecBal <- withElectrs Rpc.getBalance ($ Left $ OnChainAddress addr)
        liftIO $ elecBal `shouldSatisfy` isRight
        case elecBal of
          Right bal -> liftIO $ confirmed bal `shouldSatisfy` (> 0)
          Left _ -> error "Error getting balance"
