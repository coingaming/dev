module MathSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Math.Swap as Math
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  it "newSwapIntoLnMinAmt abs" $
    Math.newSwapIntoLnMinAmt 20000000
      `shouldBe` 12000000
  it "newSwapIntoLnMinAmt perc" $
    Math.newSwapIntoLnMinAmt 1000000000
      `shouldBe` 502009000
  itEnv "newSwapCapM abs" $ do
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
  itEnv "newSwapCapM perc" $ do
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
