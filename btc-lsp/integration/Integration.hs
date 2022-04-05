module Integration
  ( main,
  )
where

import BtcLsp.Import
import IntegrationSpec
import Test.Hspec.Formatters
import Test.Hspec.Runner
import TestWithLndLsp (mainTestSetup)

main :: IO ()
main = do
  liftIO $ print ("1=====TESTTESTTEST======" :: Text)
  mainTestSetup
  liftIO $ print ("2=====TESTTESTTEST======" :: Text)
  hspecWith
    defaultConfig
      { configFormatter = Just progress
      }
    spec
