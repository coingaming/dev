module Main
  ( main,
  )
where

import BtcLsp.Import
import Test.Hspec.Runner
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "Test" $ do
    it "test" $ do
      True `shouldBe` True
