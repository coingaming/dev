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
    satMsat :: [(Btc.BTC, MSat)]
    satMsat =
      [ (0.00000001, MSat 1000),
        (0.00000101, MSat 101000),
        (1.00000101, MSat 100000101000)
      ]
