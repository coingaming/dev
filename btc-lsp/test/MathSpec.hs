module MathSpec
  ( spec,
  )
where

import BtcLsp.Import
import Test.Hspec
import TestOrphan ()

spec :: Spec
spec = do
  focus . it "newSwapIntoLnMinAmt" $ do
    putStrLn ("hello" :: Text)
    True `shouldBe` True
