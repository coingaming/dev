module Main
  ( main,
  )
where

import ElectrsClient.Import.External
import qualified Spec
import Test.Hspec.Formatters
import Test.Hspec.Runner

main :: IO ()
main = do
  --TestAppM.mainTestSetup
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    Spec.spec
