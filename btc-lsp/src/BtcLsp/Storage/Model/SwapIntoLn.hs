{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.SwapIntoLn
  ( createIgnoreSql,
    updateWaitingPeerSql,
    updateWaitingChanSql,
    updateWaitingFundLnSql,
    updateExpiredSql,
    updateSucceededSql,
    getSwapsWaitingPeerSql,
    getSwapsWaitingChanSql,
    getSwapsWaitingLnFundSql,
    getSwapsAboutToExpirySql,
    getSwaps,
    getByUuidSql,
    getByFundAddressSql,
    withLockedRowSql,
    UtxoInfo (..),
    SwapInfo (..),
  )
where

import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Math.Swap as Math
import qualified BtcLsp.Storage.Util as Util

createIgnoreSql ::
  ( MonadIO m
  ) =>
  Entity User ->
  LnInvoice 'Fund ->
  RHash ->
  OnChainAddress 'Fund ->
  OnChainAddress 'Refund ->
  UTCTime ->
  Privacy ->
  ReaderT Psql.SqlBackend m (Entity SwapIntoLn)
createIgnoreSql userEnt fundInv fundHash fundAddr refundAddr expAt chanPrivacy = do
  ct <- getCurrentTime
  uuid <- newUuid
  --
  -- NOTE : Set initial amount to zero because
  -- we don't know how much user will deposit
  -- into on-chain address.
  --
  Psql.upsertBy
    (UniqueSwapIntoLnFundInvHash fundHash)
    SwapIntoLn
      { swapIntoLnUuid = uuid,
        swapIntoLnUserId = entityKey userEnt,
        swapIntoLnFundInvoice = fundInv,
        swapIntoLnFundInvHash = fundHash,
        swapIntoLnFundAddress = fundAddr,
        swapIntoLnFundProof = Nothing,
        swapIntoLnRefundAddress = refundAddr,
        swapIntoLnChanCapUser = Money 0,
        swapIntoLnChanCapLsp = Money 0,
        swapIntoLnFeeLsp = Money 0,
        swapIntoLnFeeMiner = Money 0,
        swapIntoLnStatus = SwapWaitingFundChain,
        swapIntoLnPrivacy = chanPrivacy,
        swapIntoLnExpiresAt = expAt,
        swapIntoLnInsertedAt = ct,
        swapIntoLnUpdatedAt = ct
      }
    [ SwapIntoLnUpdatedAt
        Psql.=. Psql.val ct
    ]

updateWaitingPeerSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  SwapCap ->
  ReaderT Psql.SqlBackend m ()
updateWaitingPeerSql sid cap = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnChanCapUser
          Psql.=. Psql.val (swapCapUsr cap),
        SwapIntoLnChanCapLsp
          Psql.=. Psql.val (swapCapLsp cap),
        SwapIntoLnFeeLsp
          Psql.=. Psql.val (swapCapFee cap),
        SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingPeer,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val sid
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     `Psql.in_` Psql.valList
                       [ SwapWaitingFundChain,
                         SwapWaitingPeer
                       ]
                 )

updateWaitingChanSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateWaitingChanSql id0 = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingChan,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val id0
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapWaitingPeer
                 )

updateWaitingFundLnSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateWaitingFundLnSql id0 = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingFundLn,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val id0
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapWaitingChan
                 )

updateExpiredSql ::
  ( MonadIO m,
    KatipContext m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateExpiredSql rowId = do
  ct <- getCurrentTime
  qty <- Psql.updateCount $ \row -> do
    Psql.set
      row
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapExpired,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val rowId
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     `Psql.in_` Psql.valList
                       [ SwapWaitingFundChain,
                         SwapWaitingPeer
                       ]
                 )
  when (qty /= 1)
    . $(logTM) ErrorS
    . logStr
    $ "Wrong expiry update result "
      <> inspect qty
      <> " for the swap "
      <> inspect rowId

updateSucceededSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  RPreimage ->
  ReaderT Psql.SqlBackend m ()
updateSucceededSql sid rp = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnFundProof
          Psql.=. Psql.val (Just rp),
        SwapIntoLnStatus
          Psql.=. Psql.val SwapSucceeded,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val sid
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapWaitingFundLn
                 )

getSwapsWaitingPeerSql ::
  ( MonadIO m
  ) =>
  ReaderT
    Psql.SqlBackend
    m
    [ ( Entity SwapIntoLn,
        Entity User
      )
    ]
getSwapsWaitingPeerSql =
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` user) -> do
      Psql.on
        ( swap Psql.^. SwapIntoLnUserId
            Psql.==. user Psql.^. UserId
        )
      Psql.where_
        ( swap Psql.^. SwapIntoLnStatus
            Psql.==. Psql.val SwapWaitingPeer
        )
      --
      -- TODO : some sort of exp backoff in case
      -- where user node is offline for a long time.
      -- Maybe limits, some proper retries etc.
      --
      pure (swap, user)

getSwapsWaitingChanSql ::
  ( MonadIO m
  ) =>
  ReaderT
    Psql.SqlBackend
    m
    [ ( Entity SwapIntoLn,
        Entity User
      )
    ]
getSwapsWaitingChanSql =
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` user) -> do
      Psql.on
        ( swap Psql.^. SwapIntoLnUserId
            Psql.==. user Psql.^. UserId
        )
      Psql.where_
        ( swap Psql.^. SwapIntoLnStatus
            Psql.==. Psql.val SwapWaitingChan
        )
      --
      -- TODO : some sort of exp backoff in case
      -- where user node is offline for a long time.
      -- Maybe limits, some proper retries etc.
      --
      pure (swap, user)

getSwaps ::
  ( MonadIO m
  ) =>
  ReaderT
    Psql.SqlBackend
    m
    [ ( Entity SwapIntoLn,
        Entity User
      )
    ]
getSwaps =
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` user) -> do
      Psql.on
        ( swap Psql.^. SwapIntoLnUserId
            Psql.==. user Psql.^. UserId
        )
--      Psql.where_
--        ( swap Psql.^. SwapIntoLnStatus
--            Psql.==. Psql.val SwapWaitingFundChain
--        )
      --
      -- TODO : some sort of exp backoff in case
      -- where user node is offline for a long time.
      -- Maybe limits, some proper retries etc.
      --
      pure (swap, user)

getSwapsWaitingLnFundSql ::
  ( MonadIO m
  ) =>
  ReaderT
    Psql.SqlBackend
    m
    [ ( Entity SwapIntoLn,
        Entity User,
        Entity LnChan
      )
    ]
getSwapsWaitingLnFundSql =
  Psql.select $
    Psql.from $
      \( swap
           `Psql.InnerJoin` user
           `Psql.InnerJoin` chan
         ) -> do
          Psql.on
            ( Psql.just (swap Psql.^. SwapIntoLnId)
                Psql.==. chan Psql.^. LnChanSwapIntoLnId
            )
          Psql.on
            ( swap Psql.^. SwapIntoLnUserId
                Psql.==. user Psql.^. UserId
            )
          Psql.where_
            ( ( chan Psql.^. LnChanStatus
                  Psql.==. Psql.val LnChanStatusActive
              )
                Psql.&&. ( swap Psql.^. SwapIntoLnStatus
                             Psql.==. Psql.val SwapWaitingFundLn
                         )
            )
          --
          -- TODO : some sort of exp backoff in case
          -- where user node is offline for a long time.
          -- Maybe limits, some proper retries etc.
          --
          pure (swap, user, chan)

getSwapsAboutToExpirySql ::
  ( MonadIO m
  ) =>
  ReaderT Psql.SqlBackend m [Entity SwapIntoLn]
getSwapsAboutToExpirySql = do
  nearExpTime <- getFutureTime Math.swapExpiryLimitInternal
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( ( row Psql.^. SwapIntoLnStatus
              `Psql.in_` Psql.valList
                --
                -- TODO : somehow handle corner case
                -- where channel is opening or already
                -- opened and waiting for the swap,
                -- but swap invoice has been expired.
                -- Maybe ask user for the new invoice in
                -- this case? Or maybe we can use keysend
                -- feature?
                --
                [ SwapWaitingFundChain,
                  SwapWaitingPeer
                ]
          )
            Psql.&&. ( row Psql.^. SwapIntoLnExpiresAt
                         Psql.<. Psql.val nearExpTime
                     )
        )
      pure row

data UtxoInfo = UtxoInfo
  { utxoInfoUtxo :: Entity SwapUtxo,
    utxoInfoBlock :: Entity Block
  }
  deriving stock
    ( Eq,
      Show
    )

data SwapInfo = SwapInfo
  { swapInfoSwap :: Entity SwapIntoLn,
    swapInfoUser :: Entity User,
    swapInfoUtxo :: [UtxoInfo],
    swapInfoChan :: [Entity LnChan]
  }
  deriving stock
    ( Eq,
      Show
    )

getByUuidSql ::
  ( MonadIO m
  ) =>
  Uuid 'SwapIntoLnTable ->
  ReaderT Psql.SqlBackend m (Maybe SwapInfo)
getByUuidSql uuid =
  (prettifyGetByUuid <$>) $
    Psql.select $
      Psql.from $
        \( mUtxo
             `Psql.InnerJoin` mBlock
             `Psql.RightOuterJoin` swap
             `Psql.LeftOuterJoin` mChan
             `Psql.InnerJoin` user
           ) -> do
            Psql.on
              ( swap Psql.^. SwapIntoLnUserId
                  Psql.==. user Psql.^. UserId
              )
            Psql.on
              ( mChan Psql.?. LnChanSwapIntoLnId
                  Psql.==. Psql.just
                    ( Psql.just $
                        swap Psql.^. SwapIntoLnId
                    )
              )
            Psql.on
              ( mUtxo Psql.?. SwapUtxoSwapIntoLnId
                  Psql.==. Psql.just (swap Psql.^. SwapIntoLnId)
              )
            Psql.on
              ( mUtxo Psql.?. SwapUtxoBlockId
                  Psql.==. mBlock Psql.?. BlockId
              )
            Psql.where_
              ( swap Psql.^. SwapIntoLnUuid
                  Psql.==. Psql.val uuid
              )
            pure (mUtxo, mBlock, mChan, swap, user)

prettifyGetByUuid ::
  [ ( Maybe (Entity SwapUtxo),
      Maybe (Entity Block),
      Maybe (Entity LnChan),
      Entity SwapIntoLn,
      Entity User
    )
  ] ->
  Maybe SwapInfo
prettifyGetByUuid = \case
  [] ->
    Nothing
  xs@((_, _, _, swap, user) : _) ->
    Just
      SwapInfo
        { swapInfoSwap = swap,
          swapInfoUser = user,
          swapInfoUtxo =
            ( \(mUtxo, mBlock, _, _, _) ->
                maybe
                  mempty
                  pure
                  $ UtxoInfo
                    <$> mUtxo
                    <*> mBlock
            )
              =<< xs,
          swapInfoChan =
            nubOrd $
              ( \(_, _, mChan, _, _) ->
                  maybe
                    mempty
                    pure
                    mChan
              )
                =<< xs
        }

getByFundAddressSql ::
  ( MonadIO m
  ) =>
  OnChainAddress 'Fund ->
  ReaderT Psql.SqlBackend m (Maybe (Entity SwapIntoLn))
getByFundAddressSql =
  Util.lockByUnique
    . UniqueSwapIntoLnFundAddress

withLockedRowSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  (SwapStatus -> Bool) ->
  (SwapIntoLn -> ReaderT Psql.SqlBackend m a) ->
  ReaderT Psql.SqlBackend m (Either (Entity SwapIntoLn) a)
withLockedRowSql rowId pre action = do
  rowVal <- Util.lockByRow rowId
  if pre $ swapIntoLnStatus rowVal
    then Right <$> action rowVal
    else pure . Left $ Entity rowId rowVal
