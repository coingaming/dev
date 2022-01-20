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
create userEnt fundInv fundAddr refundAddr userCap expAt =
  runSql $ do
    ct <- getCurrentTime
    Psql.upsertBy
      (UniqueSwapIntoLn fundInv)
      SwapIntoLn
        { swapIntoLnUserId = entityKey userEnt,
          swapIntoLnFundInvoice = fundInv,
          swapIntoLnFundAddress = fundAddr,
          swapIntoLnRefundAddress = refundAddr,
          swapIntoLnChanCapUser = userCap,
          swapIntoLnChanCapLsp = newChanCapLsp userCap,
          swapIntoLnFeeLsp = newSwapIntoLnFee userCap,
          swapIntoLnFeeMiner = Money 0,
          swapIntoLnStatus = SwapWaitingFund,
          swapIntoLnExpiresAt = expAt,
          swapIntoLnInsertedAt = ct,
          swapIntoLnUpdatedAt = ct
        }
      [ SwapIntoLnFundInvoice Psql.=. Psql.val fundInv
      ]
