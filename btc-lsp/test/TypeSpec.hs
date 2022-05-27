module TypeSpec
  ( spec,
  )
where

import BtcLsp.Import
import Test.Hspec

spec :: Spec
spec = do
  it "Swap statuses groups are complete" $
    swapStatusChain <> swapStatusLn <> swapStatusFinal
      `shouldBe` [minBound .. maxBound]
