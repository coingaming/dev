module TestWithLndAlice
  ( itEnv,
    xitEnv,
    module ReExport,
  )
where

import BtcLsp.Import
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
