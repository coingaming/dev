{-# LANGUAGE TypeApplications #-}

module BtcLsp.Math.OnChain
  ( trySatToMsat,
    tryMsatToSat,
    trySatToMsatT,
    tryMsatToSatT,
    trxDustLimit,
    trxHeadSize,
    trxInSize,
    trxOutSize,
    InQty (..),
    OutQty (..),
    SatPerVbyte (..),
    minFeeRate,
    trxEstSize,
    trxEstFee,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Network.Bitcoin as Btc
import qualified Universum

trySatToMsat ::
  Btc.BTC ->
  Either Failure Msat
trySatToMsat =
  first (FailureInt . FailureMath . Universum.show)
    . ( from @Natural
          `composeTryRhs` tryFrom @Integer
            `composeTryLhs` ((* 1000) . from)
      )

tryMsatToSat ::
  Msat ->
  Either Failure Btc.BTC
tryMsatToSat =
  first (FailureInt . FailureMath . Universum.show)
    . ( tryFrom @Rational @Btc.BTC
          `composeTryLhs` ((% 100000000000) . via @Natural)
      )

trySatToMsatT ::
  ( Monad m
  ) =>
  Btc.BTC ->
  ExceptT Failure m Msat
trySatToMsatT =
  except . trySatToMsat

tryMsatToSatT ::
  ( Monad m
  ) =>
  Msat ->
  ExceptT Failure m Btc.BTC
tryMsatToSatT =
  except . tryMsatToSat

trxDustLimit :: Msat
trxDustLimit =
  Msat $ 546 * 1000

--
-- NOTE : estimations are for the P2WPKH only
--

trxHeadSize :: Vbyte
trxHeadSize =
  Vbyte $ 105 % 10

trxInSize :: Vbyte
trxInSize =
  Vbyte 68

trxOutSize :: Vbyte
trxOutSize =
  Vbyte 31

newtype InQty = InQty
  { unInQty :: Natural
  }
  deriving newtype (Eq, Ord, Show, Num)
  deriving stock (Generic)

instance Out InQty

instance From InQty Natural

instance From Natural InQty

newtype OutQty = OutQty
  { unOutQty :: Natural
  }
  deriving newtype (Eq, Ord, Show, Num)
  deriving stock (Generic)

instance Out OutQty

instance From OutQty Natural

instance From Natural OutQty

newtype SatPerVbyte = SatPerVbyte
  { unSatPerVbyte :: Ratio Natural
  }
  deriving newtype (Eq, Ord, Show, Num)
  deriving stock (Generic)

instance Out SatPerVbyte

instance From SatPerVbyte (Ratio Natural)

instance From (Ratio Natural) SatPerVbyte

minFeeRate :: SatPerVbyte
minFeeRate = 1

trxEstSize :: InQty -> OutQty -> Vbyte
trxEstSize inQty outQty =
  trxHeadSize
    + Vbyte (via @Natural inQty) * trxInSize
    --
    -- TODO : LND estimator always requires +1 vout as a change
    -- even if change does not exit. So we should overpay
    -- a bit for non-existent output to use LND PSBTs.
    -- https://github.com/lightningnetwork/lnd/issues/5739
    --
    + Vbyte (via @Natural (outQty + 1)) * trxOutSize
    --
    -- TODO : For some reason LND estimator
    -- requires +1 vbyte overhead.
    --
    + Vbyte 1

trxEstFee ::
  InQty ->
  OutQty ->
  SatPerVbyte ->
  Msat
trxEstFee inQty outQty satPerVbyte =
  from @Natural
    . (* 1000)
    . (ceiling :: Ratio Natural -> Natural)
    $ from (trxEstSize inQty outQty) * from satPerVbyte
