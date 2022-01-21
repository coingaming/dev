module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Import
import qualified BtcLsp.Thread.Server as Server
import Test.Hspec
import TestWithPaymentsPartner

spec :: Spec
spec =
  itEnv "SwapIntoLn" $
    withSpawnLink Server.apply . const $ do
      -- Let gRPC server spawn
      sleep $ MicroSecondsDelay 100
      --
      -- TODO : implement withGCEnv!!!
      --
      gcEnv <- getGCEnv
      res <- Client.swapIntoLn gcEnv defMessage
      putStrLn $ inspectStr res
      liftIO $ True `shouldBe` True
