{-# LANGUAGE TypeApplications #-}

module BtcLsp.Storage.Model.SwapIntoLn
  ( create,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

create ::
  ( Storage m
  ) =>
  Entity User ->
  LnInvoice 'Fund ->
  OnChainAddress 'Fund ->
  OnChainAddress 'Refund ->
  Money 'Usr 'Ln 'Fund ->
  UTCTime ->
  m (Entity SwapIntoLn)
create
  userEnt
  fundInvoice
  fundAddress
  refundAddress
  chanCapUser
  expiresAt = runSql $ do
    ct <-
      liftIO getCurrentTime
    Psql.upsertBy
      (UniqueSwapIntoLn nonce)
      SwapIntoLn
        { swapIntoLnUserId = entityKey userEnt,
          swapIntoLnNonce = nonce,
          swapIntoLnFundInvoice = fundInvoice,
          swapIntoLnFundAddress = fundAddress,
          swapIntoLnRefundAddress = refundAddress,
          swapIntoLnChanCapUser = chanCapUser,
          swapIntoLnChanCapLsp = newChanCapLsp chanCapUser,
          swapIntoLnFeeLsp = newSwapIntoLnFee chanCapUser,
          swapIntoLnFeeMiner = Money 0,
          swapIntoLnStatus = SwapNew,
          swapIntoLnExpiresAt = expiresAt,
          swapIntoLnInsertedAt = ct,
          swapIntoLnUpdatedAt = ct
        }
      [ SwapIntoLnNonce Psql.=. Psql.val nonce
      ]
    where
      nonce = userLatestNonce $ entityVal userEnt
