module Main
  ( main,
  )
where

import BtcLsp.Import
import qualified Spec
import Test.Hspec.Formatters
import Test.Hspec.Runner
import TestWithLndLsp (mainTestSetup)

main :: IO ()
main = do
  mainTestSetup
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    Spec.spec
