module BtcLsp.Storage.Model.SwapIntoLn
  ( createIgnore,
    updateWaitingPeerSql,
    updateWaitingChanSql,
    updateWaitingFundLnSql,
    updateSucceededSql,
    getFundedSwaps,
    getSwapsToSettle,
    getByUuid,
    getByFundAddress,
    withLockedExtantRow,
    UtxoInfo (..),
    SwapInfo (..),
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified LndClient as Lnd

createIgnore ::
  ( Storage m
  ) =>
  Entity User ->
  LnInvoice 'Fund ->
  RHash ->
  OnChainAddress 'Fund ->
  OnChainAddress 'Refund ->
  UTCTime ->
  m (Entity SwapIntoLn)
createIgnore userEnt fundInv fundHash fundAddr refundAddr expAt =
  runSql $ do
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
                     Psql.==. Psql.val SwapWaitingFundChain
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

getFundedSwaps ::
  ( Storage m
  ) =>
  m
    [ ( Entity SwapIntoLn,
        Entity User
      )
    ]
getFundedSwaps = runSql $
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

getSwapsToSettle ::
  ( Storage m
  ) =>
  m
    [ ( Entity SwapIntoLn,
        Entity User,
        Entity LnChan
      )
    ]
getSwapsToSettle =
  runSql $
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
                               Psql.==. Psql.val SwapWaitingChan
                           )
              )
            --
            -- TODO : some sort of exp backoff in case
            -- where user node is offline for a long time.
            -- Maybe limits, some proper retries etc.
            --
            pure (swap, user, chan)

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

getByUuid ::
  ( Storage m
  ) =>
  Uuid 'SwapIntoLnTable ->
  m (Maybe SwapInfo)
getByUuid uuid =
  runSql . (prettifyGetByUuid <$>) $
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
            ( \(_, _, mChan, _, _) ->
                maybe
                  mempty
                  pure
                  mChan
            )
              =<< xs
        }

getByFundAddress ::
  ( Storage m
  ) =>
  OnChainAddress 'Fund ->
  m (Maybe (Entity SwapIntoLn))
getByFundAddress =
  runSql
    . Psql.getBy
    . UniqueSwapIntoLnFundAddress

withLockedExtantRow ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  (SwapIntoLn -> ReaderT Psql.SqlBackend m ()) ->
  ReaderT Psql.SqlBackend m ()
withLockedExtantRow rowId action = do
  ct <- getCurrentTime
  let expTime = addSeconds (Lnd.Seconds 300) ct
  let finSS = [SwapSucceeded, SwapExpired]
  swapVal <- lockByRow rowId
  if (swapIntoLnExpiresAt swapVal < expTime)
    && notElem (swapIntoLnStatus swapVal) finSS
    then Psql.update $ \row -> do
      Psql.set
        row
        [ SwapIntoLnStatus
            Psql.=. Psql.val SwapExpired,
          SwapIntoLnUpdatedAt
            Psql.=. Psql.val ct
        ]
      Psql.where_
        ( ( row Psql.^. SwapIntoLnId
              Psql.==. Psql.val rowId
          )
            Psql.&&. ( row Psql.^. SwapIntoLnExpiresAt
                         Psql.<. Psql.val expTime
                     )
            Psql.&&. ( row Psql.^. SwapIntoLnStatus
                         `Psql.notIn` Psql.valList finSS
                     )
        )
    else action swapVal
