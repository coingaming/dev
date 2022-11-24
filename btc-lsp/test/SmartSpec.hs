module SmartSpec
  ( spec,
  )
where

import qualified BtcLsp.Data.Smart as Smart
import BtcLsp.Import
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.RPC.Silent as Lnd
import Test.Hspec
import TestAppM

spec :: Spec
spec = do
  itEnvT @'LndLsp "newOnChainAddressT succeeds" $ do
    raw <-
      Lnd.address
        <$> withLndTestT
          LndAlice
          Lnd.newAddress
          ( $
              Lnd.NewAddressRequest
                { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
                  Lnd.account = Nothing
                }
          )
    res <- Smart.newOnChainAddressT $ from raw
    liftIO $ raw `shouldBe` unOnChainAddress res
  itEnv @'LndLsp "newOnChainAddressT fails" $ do
    res <- runExceptT $ do
      raw <-
        Lnd.address
          <$> withLndTestT
            LndAlice
            Lnd.newAddress
            ( $
                Lnd.NewAddressRequest
                  { Lnd.addrType = Lnd.NESTED_PUBKEY_HASH,
                    Lnd.account = Nothing
                  }
            )
      Smart.newOnChainAddressT $ from raw
    liftIO $
      res `shouldBe` Left (FailureInp FailureNonSegwitAddr)
  itEnv @'LndLsp "newOnChainAddressT throws" $ do
    res <-
      Smart.newOnChainAddress $ from @Text "hello"
    liftIO $
      res `shouldBe` Left (FailureInp FailureNonValidAddr)
