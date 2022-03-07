{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Data.Orphan () where

import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified LndClient as Lnd
import qualified Network.Bitcoin.BlockChain as Btc
import qualified Text.PrettyPrint as PP
import qualified Universum
import qualified Witch

instance From Text Lnd.PaymentRequest

instance From Lnd.PaymentRequest Text

instance From Word64 MSat

instance From MSat Word64

instance From Word64 Lnd.Seconds

instance From Lnd.Seconds Word64

deriving stock instance Generic Btc.Block

instance Out Btc.Block

Psql.derivePersistField "Btc.BlockHeight"

instance Out Natural where
  docPrec x =
    docPrec x . into @Integer
  doc =
    docPrec 0

instance
  (Psql.ToBackendKey Psql.SqlBackend a) =>
  TryFrom (Psql.Key a) Natural
  where
  tryFrom =
    tryFrom `composeTryLhs` Psql.fromSqlKey

instance
  (Psql.ToBackendKey Psql.SqlBackend a) =>
  TryFrom Natural (Psql.Key a)
  where
  tryFrom =
    Psql.toSqlKey `composeTryRhs` tryFrom

instance Out SomeException where
  docPrec _ =
    PP.text . Universum.show
  doc =
    docPrec 0
