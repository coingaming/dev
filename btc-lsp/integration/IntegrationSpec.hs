{-# LANGUAGE TypeApplications #-}

module IntegrationSpec
  ( spec,
  )
where

import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import hiding (setGrpcCtx, setGrpcCtxT)
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec =
    itEnv "TestTest" $ liftIO $ True `shouldBe` True
