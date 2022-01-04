module Main
  ( main,
  )
where

import Lsp.Import
import qualified Spec
import Test.Hspec.Formatters
import Test.Hspec.Runner
import TestWithPaymentsPartner (mainTestSetup)

main :: IO ()
main = do
  mainTestSetup
  hspecWith defaultConfig {configFormatter = Just progress} Spec.spec
