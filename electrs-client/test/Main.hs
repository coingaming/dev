module Main
  ( main,
  )
where

import ElectrsClient.Import.External
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.BtcEnv as Btc
import qualified Spec
import Test.Hspec.Formatters
import Test.Hspec.Runner

main :: IO ()
main = do
  void $ Btc.withBtc Btc.generate $ \f -> f 105 Nothing
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    Spec.spec
