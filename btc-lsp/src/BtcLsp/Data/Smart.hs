module BtcLsp.Data.Smart
  ( newOnChainAddress,
    newOnChainAddressT,
  )
where

import BtcLsp.Class.Env
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Data.Text as T
import qualified Network.Bitcoin.Wallet as Btc

newOnChainAddress ::
  ( Env m
  ) =>
  UnsafeOnChainAddress mrel ->
  m (Either Failure (OnChainAddress mrel))
newOnChainAddress unsafeAddr = do
  let txtAddr = from unsafeAddr
  eRes <- withBtc Btc.getAddrInfo ($ txtAddr)
  pure $ case eRes of
    Left e@(FailureBitcoind (OtherError txt)) ->
      if "Not a valid Bech32 or Base58 encoding" `T.isInfixOf` txt
        then Left FailureNonValidAddr
        else Left e
    Left e ->
      Left e
    Right res ->
      if Btc.isWitness res
        then Right $ OnChainAddress txtAddr
        else Left FailureNonSegwitAddr

newOnChainAddressT ::
  ( Env m
  ) =>
  UnsafeOnChainAddress mrel ->
  ExceptT Failure m (OnChainAddress mrel)
newOnChainAddressT =
  ExceptT . newOnChainAddress
