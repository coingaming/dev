module TestWithLndAlice
  ( mainTestSetup,
    itEnv,
    xitEnv,
    module ReExport,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Migration (migrateAll)
import BtcLsp.Storage.Util (cleanDb)
import Test.Hspec
import TestAppM as ReExport hiding (itEnv, xitEnv)
import qualified TestAppM

itEnv ::
  String ->
  TestAppM 'LndAlice IO () ->
  SpecWith (Arg (IO ()))
itEnv =
  TestAppM.itEnv

xitEnv ::
  String ->
  TestAppM 'LndAlice IO () ->
  SpecWith (Arg (IO ()))
xitEnv =
  TestAppM.xitEnv

mainTestSetup :: IO ()
mainTestSetup =
  TestAppM.withTestEnv action
  where
    action :: TestAppM 'LndAlice IO ()
    action = do
      --unScheduleAll
      runSql cleanDb
      migrateAll
