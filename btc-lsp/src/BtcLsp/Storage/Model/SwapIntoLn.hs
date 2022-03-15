module BtcLsp.Storage.Model.SwapIntoLn
  ( createIgnore,
    updateFundedSql,
    updateWaitingChan,
    updateSettled,
    getFundedSwaps,
    getSwapsToSettle,
    getByFundAddress,
    getLatestSwapT,
    getWaitingFundSql
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
  UTCTime ->
  m (Entity SwapIntoLn)
createIgnore userEnt fundInv fundAddr refundAddr expAt =
  runSql $ do
    ct <- getCurrentTime
    --
    -- NOTE : Set initial amount to zero because
    -- we don't know how much user will deposit
    -- into on-chain address.
    --
    let userCap = Money 0
    Psql.upsertBy
      (UniqueSwapIntoLnFundInvoice fundInv)
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
      [ SwapIntoLnFundInvoice
          Psql.=. Psql.val fundInv
      ]

updateFundedSql ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  Money 'Usr 'Ln 'Fund ->
  Money 'Lsp 'Ln 'Fund ->
  Money 'Lsp 'OnChain 'Gain ->
  ReaderT Psql.SqlBackend m ()
updateFundedSql sid usrCap lspCap lspFee = do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnChanCapUser
          Psql.=. Psql.val usrCap,
        SwapIntoLnChanCapLsp
          Psql.=. Psql.val lspCap,
        SwapIntoLnFeeLsp
          Psql.=. Psql.val lspFee,
        SwapIntoLnStatus
          Psql.=. Psql.val SwapFunded
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
  Psql.select $ Psql.from $ \row -> do
    Psql.where_ ((row Psql.^. SwapIntoLnStatus Psql.==. Psql.val SwapWaitingFund) Psql.&&.
      (row Psql.^. SwapIntoLnExpiresAt Psql.<. Psql.now_))
    pure row


updateWaitingChan ::
  ( Storage m
  ) =>
  OnChainAddress 'Fund ->
  m ()
updateWaitingChan addr = runSql $ do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingChan
      ]
    Psql.where_ $
      ( row Psql.^. SwapIntoLnFundAddress
          Psql.==. Psql.val addr
      )
        Psql.&&. ( row Psql.^. SwapIntoLnStatus
                     Psql.==. Psql.val SwapWaitingFund
                 )

--
-- TODO : store preimage???
--
updateSettled ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  m ()
updateSettled sid = runSql $ do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapSucceeded
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
        Entity User
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
