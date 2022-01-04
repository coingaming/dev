{-# LANGUAGE TemplateHaskell #-}

module Lsp.Storage.Model.LnChannel
  ( createIgnore,
    getByChannelPoint,
  )
where

import qualified LndClient as Lnd
import Lsp.Import
import qualified Lsp.Import.Psql as Psql

createIgnore ::
  ( Storage m
  ) =>
  TxId 'Funding ->
  Vout 'Funding ->
  LnChannelStatus ->
  Maybe Lnd.NodePubKey ->
  Maybe Lnd.NodeLocation ->
  m (Psql.Entity LnChannel)
createIgnore txid vout ss nodeKey nodeLoc = runSql $ do
  Psql.upsertBy
    (UniqueLnChannel txid vout)
    this
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
    [ LnChannelFundingTxId Psql.=. Psql.val txid,
      LnChannelFundingVout Psql.=. Psql.val vout
    ]
  where
    this =
      LnChannel
        { lnChannelFundingTxId = txid,
          lnChannelFundingVout = vout,
          lnChannelClosingTxId = Nothing,
          lnChannelStatus = ss,
          lnChannelLocalBalance = Nothing,
          lnChannelRemoteBalance = Nothing,
          lnChannelNodeKey = nodeKey,
          lnChannelNodeLoc = nodeLoc
        }

getByChannelPoint ::
  (Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Psql.Entity LnChannel))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChannel txid vout
