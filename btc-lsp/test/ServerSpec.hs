module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Import
import qualified BtcLsp.Thread.Server as Server
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
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
      liftIO $
        res
          `shouldSatisfy` ( \case
                              Left {} ->
                                False
                              Right msg ->
                                isJust $
                                  msg ^. SwapIntoLn.maybe'success
                          )
