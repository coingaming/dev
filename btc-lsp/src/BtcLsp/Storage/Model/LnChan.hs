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
  Psql.upsertBy
    (UniqueLnChan txid vout)
    (this ct)
    --
    -- TODO : this update is redundant, but upsertBy is
    -- not working with mempty update argument -
    -- probably it's a bug in Esqueleto implementation,
    -- check it in latest version, and if not fixed -
    -- report issue or just fix it.
    --
    -- UPDATE : reported in github
    -- https://github.com/bitemyapp/esqueleto/issues/294
    --
    [ LnChanFundingTxId Psql.=. Psql.val txid,
      LnChanFundingVout Psql.=. Psql.val vout
    ]
  where
    this ct0 =
      LnChan
        { lnChanSwapIntoLnId = swapId,
          lnChanFundingTxId = txid,
          lnChanFundingVout = vout,
          lnChanClosingTxId = Nothing,
          lnChanNumUpdates = 0,
          lnChanStatus = ss,
          lnChanInsertedAt = ct0,
          lnChanUpdatedAt = ct0
        }

getByChannelPoint ::
  (Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Entity LnChan))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChan txid vout
