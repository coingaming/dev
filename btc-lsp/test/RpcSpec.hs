{-# LANGUAGE TemplateHaskell #-}

module RpcSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ElectrsRpc as Rpc
import BtcLsp.Rpc.Helper
import LndClient.Data.NewAddress (NewAddressResponse (NewAddressResponse))
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.RPC.Katip as Lnd
import Network.Bitcoin.Mining (generateToAddress)
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  itEnv "getMsatPerByte" $ do
    x <- getMsatPerByte
    liftIO $ x `shouldBe` Just 1000
  itEnv "Version" $ do
    ver <- withElectrs Rpc.version ($ ())
    liftIO $ ver `shouldSatisfy` isRight
  itEnv "Get Balance" $ do
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
        elecBal <- runExceptT $ do
          let addr = coerce response
          _ <- withBtcT generateToAddress (\h -> h 3 addr Nothing)
          _ <- waitTillLastBlockProcessedT 100
          withElectrsT Rpc.getBalance ($ Left $ OnChainAddress addr)
        liftIO $ elecBal `shouldSatisfy` isRight
        case elecBal of
          Right bal -> liftIO $ confirmed bal `shouldSatisfy` (> 0)
          Left _ -> error "Error getting balance"
