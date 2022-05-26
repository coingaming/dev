module TestWithLndLsp
  ( itEnv,
    xitEnv,
    mainTestSetup,
    module ReExport,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Migration (migrateAll)
import qualified BtcLsp.Storage.Util as Util
import Test.Hspec
import TestAppM as ReExport hiding (itEnv, xitEnv)
import qualified TestAppM

itEnv ::
  String ->
  TestAppM 'LndLsp IO () ->
  SpecWith (Arg (IO ()))
itEnv =
  TestAppM.itEnv

xitEnv ::
  String ->
  TestAppM 'LndLsp IO () ->
  SpecWith (Arg (IO ()))
xitEnv =
  TestAppM.xitEnv

mainTestSetup :: IO ()
mainTestSetup =
  TestAppM.withTestEnv action
  where
    action :: TestAppM 'LndLsp IO ()
    action = do
      --unScheduleAll
      runSql Util.cleanDb
      migrateAll
