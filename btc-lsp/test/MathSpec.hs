{-# LANGUAGE TypeApplications #-}

module MathSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Math.OnChain as Math
import qualified BtcLsp.Math.Swap as Math
import qualified Network.Bitcoin as Btc
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Monadic
import TestAppM
import TestOrphan ()

spec :: Spec
spec = do
  it "newSwapIntoLnMinAmt abs" $
    Math.newSwapIntoLnMinAmt 20000000
      `shouldBe` 12000000
  it "newSwapIntoLnMinAmt perc" $
    Math.newSwapIntoLnMinAmt 1000000000
      `shouldBe` 502009000
  itEnv @'LndLsp "newSwapCapM abs" $ do
    res <- Math.newSwapCapM 12000000
    liftIO $
      res
        `shouldBe` Just
          ( SwapCap
              { swapCapUsr = 10000000,
                swapCapLsp = 10000000,
                swapCapFee = 2000000
              }
          )
  itEnv @'LndLsp "newSwapCapM perc" $ do
    res <- Math.newSwapCapM 502009000
    liftIO $
      res
        `shouldBe` Just
          ( SwapCap
              { swapCapUsr = 500000000,
                swapCapLsp = 500000000,
                swapCapFee = 2009000
              }
          )
  itProp @'LndLsp "newSwapCapM prop" $ do
    minSwp <- getSwapIntoLnMinAmt
    withRunInIO $ \run0 ->
      pure . monadicIO $ do
        swp <-
          from @Msat <$> pick arbitrary
        maybeM
          (assert $ swp < minSwp)
          ( \res -> do
              let usr = Math.swapCapUsr res
              let lsp = Math.swapCapLsp res
              let fee = Math.swapCapFee res
              assert $ swp >= minSwp
              assert $ usr > 0
              assert $ lsp > 0
              assert $ fee > 0
              assert $ usr > coerce fee
              assert $ lsp > coerce fee
              assert $ usr == coerce lsp
              assert $ (usr + coerce fee) == coerce swp
          )
          . liftIO
          . run0
          $ Math.newSwapCapM swp
  it "trySatToMsat" $
    mapM_
      ( \(sat, msat) ->
          Math.trySatToMsat sat `shouldBe` Right msat
      )
      satMsat
  it "tryMsatToSat" $
    mapM_
      ( \(sat, msat) ->
          Math.tryMsatToSat msat `shouldBe` Right sat
      )
      satMsat
  where
    satMsat :: [(Btc.BTC, Msat)]
    satMsat =
      [ (0.00000001, Msat 1000),
        (0.00000101, Msat 101000),
        (1.00000101, Msat 100000101000)
      ]
