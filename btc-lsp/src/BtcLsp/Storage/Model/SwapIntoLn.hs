module BtcLsp.Storage.Model.SwapIntoLn
  ( create,
    getFundedSwaps,
    openChannel,
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

getFundedSwaps :: (Storage m) => m [Entity SwapIntoLn]
getFundedSwaps =
  runSql $
    Psql.selectList
      [ SwapIntoLnStatus `Psql.persistEq` SwapFunded
      ]
      --
      -- TODO : some sort of exp backoff in case
      -- where user node is offline for a long time.
      -- Maybe limits, some proper retries etc.
      --
      []

openChannel :: (Monad m) => Entity SwapIntoLn -> m ()
openChannel _ =
  --
  -- TODO : improve!!! This is reckless version,
  -- we need to query Lnd for payment already being
  -- processed or not.
  --
  pure ()
