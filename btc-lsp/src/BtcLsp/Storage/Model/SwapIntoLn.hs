module BtcLsp.Storage.Model.SwapIntoLn
  ( createIgnore,
    getFundedSwaps,
    openChannel,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createIgnore ::
  ( Storage m
  ) =>
  Entity User ->
  LnInvoice 'Fund ->
  OnChainAddress 'Fund ->
  OnChainAddress 'Refund ->
  Money 'Usr 'Ln 'Fund ->
  UTCTime ->
  m (Entity SwapIntoLn)
createIgnore userEnt fundInv fundAddr refundAddr userCap expAt =
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

getFundedSwaps ::
  ( Storage m
  ) =>
  m [(Entity SwapIntoLn, Entity User)]
getFundedSwaps = runSql $
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` user) -> do
      Psql.on
        ( swap Psql.^. SwapIntoLnUserId
            Psql.==. user Psql.^. UserId
        )
      Psql.where_
        ( swap Psql.^. SwapIntoLnStatus
            Psql.==. Psql.val SwapFunded
        )
      --
      -- TODO : some sort of exp backoff in case
      -- where user node is offline for a long time.
      -- Maybe limits, some proper retries etc.
      --
      pure (swap, user)

openChannel :: (Monad m) => Entity SwapIntoLn -> m ()
openChannel _ =
  --
  -- TODO : improve!!! This is reckless version,
  -- we need to query Lnd for payment already being
  -- processed or not.
  --
  pure ()
