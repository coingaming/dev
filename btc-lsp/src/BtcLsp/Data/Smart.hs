{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Data.Smart
  ( OnChainAddress,
    unOnChainAddress,
    unsafeNewOnChainAddress,
    newOnChainAddress,
    newOnChainAddressT,
  )
where

import BtcLsp.Class.Env
import BtcLsp.Class.ToProto
import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Data.Text as T
import qualified Network.Bitcoin.Wallet as Btc
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.LowLevel as Proto

newtype OnChainAddress (mrel :: MoneyRelation) = OnChainAddress
  { unOnChainAddress0 :: Text
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      PathPiece,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out (OnChainAddress mrel)

unOnChainAddress :: OnChainAddress mrel -> Text
unOnChainAddress = unOnChainAddress0

unsafeNewOnChainAddress :: Text -> OnChainAddress mrel
unsafeNewOnChainAddress = OnChainAddress

newOnChainAddress ::
  ( Env m
  ) =>
  UnsafeOnChainAddress mrel ->
  m (Either Failure (OnChainAddress mrel))
newOnChainAddress unsafeAddr = do
  eRes <- withBtc Btc.getAddrInfo ($ txtAddr)
  case eRes of
    Left e@(FailureInt (FailurePrivate txt)) ->
      if ("Not a valid Bech32 or Base58 encoding" `T.isInfixOf` txt)
        || ("Invalid checksum" `T.isInfixOf` txt)
        then pure . Left $ FailureInp FailureNonValidAddr
        else do
          $(logTM) WarningS . logStr $
            "newOnChainAddress unexpected private failure " <> inspect e
          pure $ Left e
    Left e -> do
      $(logTM) WarningS . logStr $
        "newOnChainAddress unexpected failure " <> inspect e
      pure $
        Left e
    Right res ->
      pure $
        if Btc.isWitness res
          then Right $ OnChainAddress txtAddr
          else Left $ FailureInp FailureNonSegwitAddr
  where
    txtAddr = from unsafeAddr

newOnChainAddressT ::
  ( Env m
  ) =>
  UnsafeOnChainAddress mrel ->
  ExceptT Failure m (OnChainAddress mrel)
newOnChainAddressT =
  ExceptT . newOnChainAddress

instance ToProto (OnChainAddress mrel) Proto.OnChainAddress where
  toProto =
    newProtoVal
      . unOnChainAddress

instance ToProto (OnChainAddress 'Fund) Proto.FundOnChainAddress where
  toProto =
    newProtoVal
      . toProto @(OnChainAddress 'Fund) @Proto.OnChainAddress

instance ToProto (OnChainAddress 'Refund) Proto.RefundOnChainAddress where
  toProto =
    newProtoVal
      . toProto @(OnChainAddress 'Refund) @Proto.OnChainAddress
