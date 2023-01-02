{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Data.Type
  ( Nonce (..),
    newNonce,
    LnInvoice (..),
    LnInvoiceStatus (..),
    LnChanStatus (..),
    Liquidity (..),
    Money (..),
    FeeRate (..),
    UnsafeOnChainAddress (..),
    Seconds (..),
    LogFormat (..),
    LogStyle (..),
    YesodLog (..),
    MicroSeconds (..),
    SwapStatus (..),
    swapStatusChain,
    swapStatusLn,
    swapStatusFinal,
    Failure (..),
    FailureInternal (..),
    FailureInput (..),
    handleBtcFailureGen,
    tryFailureE,
    tryFailureT,
    tryFromE,
    tryFromT,
    SocketAddress (..),
    BlkHash (..),
    BlkHeight (..),
    BlkStatus (..),
    SwapUtxoStatus (..),
    Privacy (..),
    NodePubKeyHex (..),
    NodeUri (..),
    NodeUriHex (..),
    UtxoLockId (..),
    RHashHex (..),
    Uuid,
    unUuid,
    newUuid,
    Vbyte (..),
    RowQty (..),
    PsbtUtxo (..),
    SwapHash (..),
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Text as T
import qualified Data.ByteString.Base16 as B16
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Time.Clock as Clock
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import qualified LndClient as Lnd
import qualified LndClient.Data.OutPoint as OP
import qualified Network.Bitcoin.BlockChain as Btc
import Text.Julius (ToJavascript)
import qualified Universum
import qualified Witch
import Yesod.Core

newtype Nonce = Nonce
  { unNonce :: Word64
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out Nonce

newNonce :: (MonadIO m) => m Nonce
newNonce =
  liftIO $
    Nonce
      . utcTimeToMicros
      <$> Clock.getCurrentTime

utcTimeToMicros :: UTCTime -> Word64
utcTimeToMicros x =
  fromInteger $
    diffTimeToPicoseconds
      ( fromRational
          . toRational
          $ diffUTCTime x epoch
      )
      `div` 1000000

epoch :: UTCTime
epoch =
  posixSecondsToUTCTime 0

data LogFormat
  = Bracket
  | JSON
  deriving stock
    ( Read
    )

data LogStyle
  = DarkBg
  | LightBg
  | NoColor
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

data YesodLog
  = YesodLogAll
  | YesodLogNoMain
  | YesodLogNothing
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance FromJSON YesodLog

newtype Seconds
  = Seconds Word64
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out Seconds

newtype MicroSeconds
  = MicroSeconds Integer
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out MicroSeconds

newtype LnInvoice (mrel :: MoneyRelation) = LnInvoice
  { unLnInvoice :: Lnd.PaymentRequest
  }
  deriving newtype
    ( Eq,
      Show,
      Psql.PersistField,
      Psql.PersistFieldSql,
      PathPiece
    )
  deriving stock
    ( Generic
    )

instance Out (LnInvoice mrel)

newtype SwapHash = SwapHash Text
  deriving newtype
    ( Eq,
      Show,
      Read,
      PathPiece,
      ToJavascript,
      ToJSON
    )
  deriving stock
    ( Generic
    )

instance Out SwapHash

instance ToTypedContent (Maybe SwapHash) where
  toTypedContent = toTypedContent . toJSON

instance ToContent (Maybe SwapHash) where
  toContent = toContent . toJSON

data LnInvoiceStatus
  = LnInvoiceStatusNew
  | LnInvoiceStatusLocked
  | LnInvoiceStatusSettled
  | LnInvoiceStatusCancelled
  | LnInvoiceStatusExpired
  deriving stock
    ( Generic,
      Show,
      Read,
      Eq
    )

instance Out LnInvoiceStatus

data LnChanStatus
  = LnChanStatusPendingOpen
  | LnChanStatusOpened
  | LnChanStatusActive
  | LnChanStatusFullyResolved
  | LnChanStatusInactive
  | LnChanStatusPendingClose
  | LnChanStatusClosed
  deriving stock
    ( Generic,
      Show,
      Read,
      Eq,
      Ord
    )

instance Out LnChanStatus

newtype Liquidity (dir :: Direction) = Liquidity
  { unLiquidity :: Msat
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out (Liquidity dir)

newtype
  Money
    (owner :: Owner)
    (btcl :: BitcoinLayer)
    (mrel :: MoneyRelation) = Money
  { unMoney :: Msat
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Num,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out (Money owner btcl mrel)

instance ToMessage (Money owner btcl mrel) where
  toMessage =
    T.displayRational 1
      . (/ 1000)
      . fromIntegral
      . unMsat
      . unMoney

newtype FeeRate = FeeRate
  { unFeeRate :: Ratio Natural
  }
  deriving newtype
    ( Eq,
      Ord,
      Show
    )
  deriving stock
    ( Generic
    )

instance ToMessage FeeRate where
  toMessage =
    (<> "%")
      . T.displayRational 1
      . (* 100)
      . from @(Ratio Natural) @Rational
      . unFeeRate

newtype UnsafeOnChainAddress (mrel :: MoneyRelation) = UnsafeOnChainAddress
  { unUnsafeOnChainAddress :: Text
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      PathPiece,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out (UnsafeOnChainAddress mrel)

data SwapStatus
  = -- | Waiting on-chain funding trx with
    -- given amt from user with
    -- some confirmations.
    SwapWaitingFundChain
  | -- | Swap has been funded on-chain,
    -- need to open LN channel now.
    SwapWaitingPeer
  | -- | Channel opener thread is in progress
    SwapInPsbtThread
  | -- | Waiting channel opening trx
    -- to be mined with some confirmations.
    SwapWaitingChan
  | -- | Final statuses
    SwapSucceeded
  | SwapExpired
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic,
      Enum,
      Bounded
    )

instance Out SwapStatus

swapStatusChain :: [SwapStatus]
swapStatusChain =
  [ SwapWaitingFundChain,
    SwapWaitingPeer
  ]

swapStatusLn :: [SwapStatus]
swapStatusLn =
  [ SwapInPsbtThread,
    SwapWaitingChan
  ]

swapStatusFinal :: [SwapStatus]
swapStatusFinal =
  [ SwapSucceeded,
    SwapExpired
  ]

instance PathPiece SwapStatus where
  fromPathPiece :: Text -> Maybe SwapStatus
  fromPathPiece =
    readMaybe
      . unpack
      . T.toTitle
  toPathPiece :: SwapStatus -> Text
  toPathPiece =
    T.toLower
      . Universum.show

data Failure
  = FailureInp FailureInput
  | FailureInt FailureInternal
  deriving stock
    ( Eq,
      Show,
      Generic
    )

instance Out Failure

data FailureInput
  = FailureNonce
  | FailureNonSegwitAddr
  | FailureNonValidAddr
  deriving stock
    ( Eq,
      Show,
      Generic
    )

instance Out FailureInput

data FailureInternal
  = FailureGrpcServer Text
  | FailureGrpcClient Text
  | FailureMath Text
  | FailurePrivate Text
  | FailureRedacted
  deriving stock
    ( Eq,
      Show,
      Generic
    )

instance Out FailureInternal

handleBtcFailureGen :: (KatipContext m) => BtcFailure -> m Failure
handleBtcFailureGen e = do
  let failureText = Universum.show e :: Text
  let failureData = handleBtcFailureText failureText
  let sev =
        if failureData == FailureInp FailureNonValidAddr
          then DebugS
          else ErrorS
  $logTM sev . logStr $ "Bitcoind failure " <> failureText
  pure failureData

handleBtcFailureText :: Text -> Failure
handleBtcFailureText txt =
  if ("Not a valid Bech32 or Base58 encoding" `T.isInfixOf` txt)
    || ("Invalid checksum" `T.isInfixOf` txt)
    then FailureInp FailureNonValidAddr
    else FailureInt FailureRedacted

tryFailureE ::
  forall source target.
  ( Show source,
    Typeable source,
    Typeable target
  ) =>
  Text ->
  Either (TryFromException source target) target ->
  Either Failure target
tryFailureE label =
  first $
    FailureInt
      . FailureMath
      . (label <>)
      . (" " <>)
      . Universum.show

tryFailureT ::
  forall source target m.
  ( Show source,
    Typeable source,
    Typeable target,
    Monad m
  ) =>
  Text ->
  Either (TryFromException source target) target ->
  ExceptT Failure m target
tryFailureT label =
  except . tryFailureE label

tryFromE ::
  forall source target.
  ( Show source,
    Typeable source,
    Typeable target,
    TryFrom source target,
    'False ~ (source == target)
  ) =>
  Text ->
  source ->
  Either Failure target
tryFromE label =
  tryFailureE label . tryFrom

tryFromT ::
  forall source target m.
  ( Show source,
    Typeable source,
    Typeable target,
    TryFrom source target,
    Monad m,
    'False ~ (source == target)
  ) =>
  Text ->
  source ->
  ExceptT Failure m target
tryFromT label =
  except . tryFromE label

data SocketAddress = SocketAddress
  { socketAddressHost :: HostName,
    socketAddressPort :: PortNumber
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out SocketAddress

newtype BlkHash = BlkHash
  { unBlkHash :: Btc.BlockHash
  }
  deriving stock (Eq, Ord, Show, Generic)
  deriving newtype (Psql.PersistField, Psql.PersistFieldSql)

instance Out BlkHash

newtype BlkHeight = BlkHeight
  { unBlkHeight :: Word64
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )
  deriving newtype
    ( Num,
      Psql.PersistField,
      Psql.PersistFieldSql
    )

instance Out BlkHeight

instance ToJSON BlkHeight

instance TryFrom Btc.BlockHeight BlkHeight where
  tryFrom = BlkHeight `composeTryRhs` tryFrom

data BlkStatus
  = BlkConfirmed
  | BlkOrphan
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance Out BlkStatus

data SwapUtxoStatus
  = SwapUtxoUnspent
  | SwapUtxoUnspentDust
  | SwapUtxoUnspentChanReserve
  | SwapUtxoSpentChanSwapped
  | SwapUtxoSpentRefund
  | SwapUtxoOrphan
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance Out SwapUtxoStatus

data Privacy
  = Public
  | Private
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Enum,
      Bounded,
      Generic
    )

instance Out Privacy

newtype NodePubKeyHex = NodePubKeyHex {unNodePubKeyHex :: Text}
  deriving newtype (Eq, Ord, Show, Read, IsString)
  deriving stock (Generic)

instance TryFrom NodePubKey NodePubKeyHex where
  tryFrom src =
    NodePubKeyHex
      `composeTryRhs` ( first
                          ( TryFromException src
                              . Just
                              . toException
                          )
                          . TE.decodeUtf8'
                          . B16.encode
                          . unNodePubKey
                      )
      $ src

newtype UtxoLockId = UtxoLockId {unUtxoLockId :: ByteString}
  deriving newtype (Eq, Ord, Show, Read)
  deriving stock (Generic)

instance Out UtxoLockId

data NodeUri = NodeUri
  { nodeUriPubKey :: NodePubKey,
    nodeUriSocketAddress :: SocketAddress
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out NodeUri

newtype NodeUriHex = NodeUriHex {unNodeUriHex :: Text}
  deriving newtype (Eq, Ord, Show, Read, IsString)
  deriving stock (Generic)

instance TryFrom NodeUri NodeUriHex where
  tryFrom src =
    bimap
      (withTarget @NodeUriHex . withSource src)
      ( \pubHex ->
          NodeUriHex $
            unNodePubKeyHex pubHex
              <> "@"
              <> from host
              <> ":"
              <> from (showIntegral port)
      )
      $ tryFrom @NodePubKey @NodePubKeyHex $
        nodeUriPubKey src
    where
      sock = nodeUriSocketAddress src
      host = socketAddressHost sock
      port = socketAddressPort sock

newtype RHashHex = RHashHex
  { unRHashHex :: Text
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      PathPiece
    )
  deriving stock
    ( Generic
    )

instance Out RHashHex

instance From RHash RHashHex where
  from =
    --
    -- NOTE : decodeUtf8 in general is unsafe
    -- but here we know that it will not fail
    -- because of B16
    --
    RHashHex
      . decodeUtf8
      . B16.encode
      . unRHash

instance From RHashHex RHash where
  from =
    --
    -- NOTE : this is not RFC 4648-compliant,
    -- using only for the practical purposes
    --
    RHash
      . B16.decodeLenient
      . encodeUtf8
      . unRHashHex

newtype Uuid (tab :: Table) = Uuid
  { unUuid' :: UUID
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read
    )
  deriving stock (Generic)

unUuid :: Uuid tab -> UUID
unUuid =
  unUuid'

instance Out (Uuid tab) where
  docPrec x =
    docPrec x
      . UUID.toText
      . unUuid
  doc =
    docPrec 0

newUuid :: (MonadIO m) => m (Uuid tab)
newUuid =
  liftIO $
    Uuid <$> UUID.nextRandom

newtype Vbyte = Vbyte
  { unVbyte :: Ratio Natural
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out Vbyte

newtype RowQty = RowQty
  { unRowQty :: Int64
  }
  deriving newtype
    ( Eq,
      Ord,
      Show
    )
  deriving stock
    ( Generic
    )

instance Out RowQty

data PsbtUtxo = PsbtUtxo
  { getOutPoint :: OP.OutPoint,
    getAmt :: Msat,
    getLockId :: Maybe UtxoLockId
  }
  deriving stock (Show, Generic)

instance Out PsbtUtxo

--
-- NOTE :  we're taking advantage of
-- PostgreSQL understanding UUID values
--
instance Psql.PersistField (Uuid tab) where
  toPersistValue =
    Psql.PersistLiteral_ Psql.Escaped
      . UUID.toASCIIBytes
      . unUuid
  fromPersistValue = \case
    Psql.PersistLiteral_ Psql.Escaped x ->
      maybe
        ( Left $
            "Failed to deserialize a UUID, got literal: "
              <> inspectPlain x
        )
        ( Right
            . Uuid
        )
        $ UUID.fromASCIIBytes x
    failure ->
      Left $
        "Failed to deserialize a UUID, got: "
          <> inspectPlain failure

instance Psql.PersistFieldSql (Uuid tab) where
  sqlType =
    const $
      Psql.SqlOther "uuid"

instance ToMessage (Uuid tab) where
  toMessage =
    (<> "...")
      . T.take 5
      . UUID.toText
      . unUuid

instance PathPiece (Uuid tab) where
  fromPathPiece =
    (Uuid <$>)
      . UUID.fromText
  toPathPiece =
    UUID.toText
      . unUuid

Psql.derivePersistField "LnInvoiceStatus"
Psql.derivePersistField "LnChanStatus"
Psql.derivePersistField "SwapStatus"
Psql.derivePersistField "BlkStatus"
Psql.derivePersistField "SwapUtxoStatus"
Psql.derivePersistField "Privacy"
Psql.derivePersistField "UtxoLockId"
