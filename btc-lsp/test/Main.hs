module Main
  ( main,
  )
where

import BtcLsp.Import
import qualified Spec
import Test.Hspec.Formatters
import Test.Hspec.Runner
import qualified TestAppM

main :: IO ()
main = do
  TestAppM.mainTestSetup
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    Spec.spec
