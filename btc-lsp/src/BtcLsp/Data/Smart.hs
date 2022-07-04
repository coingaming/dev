module BtcLsp.Data.Smart
  ( newOnChainAddress,
    newOnChainAddressT,
  )
where

import BtcLsp.Class.Env
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Network.Bitcoin.Wallet as Btc

newOnChainAddress ::
  ( Env m
  ) =>
  Text ->
  m (Either Failure (OnChainAddress mrel))
newOnChainAddress raw = do
  eRes <- withBtc Btc.getAddrInfo ($ raw)
  pure $ case eRes of
    Left e -> Left e
    Right res ->
      if Btc.isWitness res
        then Right $ OnChainAddress raw
        else Left FailureNonSegwit

newOnChainAddressT ::
  ( Env m
  ) =>
  Text ->
  ExceptT Failure m (OnChainAddress mrel)
newOnChainAddressT =
  ExceptT . newOnChainAddress
