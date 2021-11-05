module GenericPrettyInstancesSpec (spec) where

import Test.Hspec
import Text.PrettyPrint.GenericPretty.Util (inspect)
import Universum hiding (show)

spec :: Spec
spec =
  it "success" $
    inspect True `shouldBe` "True"
