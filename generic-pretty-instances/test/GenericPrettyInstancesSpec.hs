{-# LANGUAGE StandaloneDeriving #-}

module GenericPrettyInstancesSpec (spec) where

import Test.Hspec
import Text.PrettyPrint.GenericPretty (Out (..))
import Text.PrettyPrint.GenericPretty.Util
  ( inspect,
    inspectPlain,
  )
import Universum hiding (show)

newtype Username = Username String

deriving stock instance Generic Username

instance Out Username

data Configuration = Configuration
  { username :: Username,
    localHost :: String
  }

deriving stock instance Generic Configuration

instance Out Configuration

spec :: Spec
spec = do
  it "Bool" $
    inspect True
      `shouldBe` "True"
  it "List" $
    inspectPlain ([1 .. 5] :: [Int])
      `shouldBe` "[ 1, 2, 3, 4, 5 ]"
  it "NestedRecord" $
    inspectPlain Configuration {username = Username "john", localHost = "127.0.0.1"}
      `shouldBe` "Configuration    { username = Username \"john\", localHost = \"127.0.0.1\" }"
