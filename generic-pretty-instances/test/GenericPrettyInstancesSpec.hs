module GenericPrettyInstancesSpec (spec) where

import Test.Hspec
import Text.PrettyPrint.GenericPretty.Util (show)
import Universum hiding (show)

spec :: Spec
spec =
  it "success" $
    show True `shouldBe` "True"
