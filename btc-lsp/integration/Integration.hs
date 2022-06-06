module Integration
  ( main,
  )
where

import BtcLsp.Import
import IntegrationSpec
import Test.Hspec.Formatters
import Test.Hspec.Runner
import TestAppM (mainTestSetup)

main :: IO ()
main = do
  mainTestSetup
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    spec
