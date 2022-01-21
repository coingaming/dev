module GenericPrettyInstancesSpec (spec) where

import Test.Hspec
import Text.PrettyPrint.GenericPretty.Util
  ( inspect,
    inspectPlain,
  )
import Universum hiding (show)

spec :: Spec
spec = do
  it "Bool" $
    inspect True
      `shouldBe` "True"
  it "List" $
    inspectPlain ([1 .. 5] :: [Int])
      `shouldBe` "[ 1, 2, 3, 4, 5 ]"
