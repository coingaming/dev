{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.LnChan
  ( createIgnore,
    getByChannelPoint,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createIgnore ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  LnChanStatus ->
  m (Entity LnChan)
createIgnore swapId txid vout ss = runSql $ do
  ct <- getCurrentTime
  Psql.update $ \swap -> do
    Psql.set
      swap
      --
      -- TODO : better status mapping
      --
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingChan,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( swap Psql.^. SwapIntoLnId
          Psql.==. Psql.val swapId
      )
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = swapId,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanNumUpdates = 0,
        lnChanStatus = ss,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct
      }
    --
    -- TODO : txid + vout update is redundant, but upsertBy is
    -- not working with mempty update argument -
    -- probably it's a bug in Esqueleto implementation,
    -- check it in latest version, and if not fixed -
    -- report issue or just fix it.
    --
    -- UPDATE : reported in github
    -- https://github.com/bitemyapp/esqueleto/issues/294
    --
    [ LnChanFundingTxId Psql.=. Psql.val txid,
      LnChanFundingVout Psql.=. Psql.val vout,
      LnChanSwapIntoLnId Psql.=. Psql.val swapId
    ]

getByChannelPoint ::
  (Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Entity LnChan))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChan txid vout
