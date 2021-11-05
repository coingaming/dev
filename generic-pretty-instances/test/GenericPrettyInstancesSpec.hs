module GenericPrettyInstancesSpec (spec) where

import Test.Hspec
import Text.PrettyPrint.GenericPretty.Util (log)
import Universum hiding (show)

spec :: Spec
spec =
  it "success" $
    log True `shouldBe` "True"
