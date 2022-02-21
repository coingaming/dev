{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.Block
  ( getLatest,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

getLatest :: (Storage m) => m (Maybe (Entity Block))
getLatest =
  runSql $
    listToMaybe
      <$> Psql.selectList
        [ BlockStatus `Psql.persistEq` BlkConfirmed
        ]
        [ Psql.Desc BlockHeight,
          Psql.LimitTo 1
        ]
