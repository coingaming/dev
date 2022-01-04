{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoStrictData #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Lsp.Data.Model where

import Database.Persist.Quasi
import Database.Persist.TH
import qualified LndClient as Lnd
import Lsp.Class.Storage
import Lsp.Data.Type
import Lsp.Import.External
import qualified Lsp.Import.Psql as Psql

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share
  [mkPersist sqlSettings, mkMigrate "migrateAuto"]
  $(persistFileWith lowerCaseSettings "config/model")

instance HasTableName LnChannel where
  getTableName = const LnChannelTable

instance Out (Psql.BackendKey Psql.SqlBackend)

deriving stock instance Generic (Psql.Key LnChannel)

instance Out (Psql.Key LnChannel)

instance Out LnChannel
