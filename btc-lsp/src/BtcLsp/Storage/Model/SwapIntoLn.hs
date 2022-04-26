module BtcLsp.Storage.Model.SwapIntoLn
  ( createIgnore,
    updateFundedSql,
    updateWaitingChan,
    updateSettled,
    getFundedSwaps,
    getSwapsToSettle,
    getByRHashHex,
    getByFundAddress,
    getLatestSwapT,
    getWaitingFundSql,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

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
    --
    -- NOTE : Set initial amount to zero because
    -- we don't know how much user will deposit
    -- into on-chain address.
    --
    Psql.upsertBy
      (UniqueSwapIntoLnFundInvHash fundHash)
      SwapIntoLn
        { swapIntoLnUserId = entityKey userEnt,
          swapIntoLnFundInvoice = fundInv,
          swapIntoLnFundInvHash = fundHash,
          swapIntoLnFundAddress = fundAddr,
          swapIntoLnFundProof = Nothing,
          swapIntoLnRefundAddress = refundAddr,
          swapIntoLnChanCapUser = Money 0,
          swapIntoLnChanCapLsp = Money 0,
          swapIntoLnFeeLsp = Money 0,
          swapIntoLnFeeMiner = Money 0,
          swapIntoLnStatus = SwapWaitingFund,
          swapIntoLnExpiresAt = expAt,
          swapIntoLnInsertedAt = ct,
          swapIntoLnUpdatedAt = ct
        }
      [ SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]

updateFundedSql ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  SwapCap ->
  ReaderT Psql.SqlBackend m ()
updateFundedSql sid cap = do
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
          Psql.=. Psql.val SwapFunded,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnId
          Psql.==. Psql.val sid
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapWaitingFund
                 )

getWaitingFundSql :: (Storage m) => ReaderT Psql.SqlBackend m [Entity SwapIntoLn]
getWaitingFundSql = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( (row Psql.^. SwapIntoLnStatus Psql.==. Psql.val SwapWaitingFund)
            Psql.&&. (row Psql.^. SwapIntoLnExpiresAt Psql.<. Psql.now_)
        )
      pure row

updateWaitingChan ::
  ( Storage m
  ) =>
  OnChainAddress 'Fund ->
  m ()
updateWaitingChan addr = runSql $ do
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
      ( row Psql.^. SwapIntoLnFundAddress
          Psql.==. Psql.val addr
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapFunded
                 )

updateSettled ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  RPreimage ->
  m ()
updateSettled sid rp = runSql $ do
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
                     Psql.==. Psql.val SwapWaitingChan
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
            Psql.==. Psql.val SwapFunded
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

getByRHashHex ::
  ( Storage m
  ) =>
  RHashHex ->
  m (Maybe (Entity SwapIntoLn, Entity User))
getByRHashHex hash =
  runSql . (listToMaybe <$>) $
    Psql.select $
      Psql.from $ \(swap `Psql.InnerJoin` user) -> do
        Psql.on
          ( swap Psql.^. SwapIntoLnUserId
              Psql.==. user Psql.^. UserId
          )
        Psql.where_
          ( swap Psql.^. SwapIntoLnFundInvHash
              Psql.==. Psql.val (from hash)
          )
        Psql.limit 1
        pure (swap, user)

getByFundAddress ::
  ( Storage m
  ) =>
  OnChainAddress 'Fund ->
  m (Maybe (Entity SwapIntoLn))
getByFundAddress =
  runSql
    . Psql.getBy
    . UniqueSwapIntoLnFundAddress

getLatestSwapT ::
  ( Storage m
  ) =>
  ExceptT Failure m (Entity SwapIntoLn)
getLatestSwapT =
  ExceptT
    . ( maybeToRight
          (FailureInternal "Missing SwapIntoLn")
          <$>
      )
    . runSql
    $ listToMaybe
      <$> Psql.selectList
        []
        [ Psql.Desc SwapIntoLnId,
          Psql.LimitTo 1
        ]
