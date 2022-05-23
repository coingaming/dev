{-# LANGUAGE TypeApplications #-}

module BtcLsp.Math.OnChain
  ( roundWord64ToMSat,
    trySatToMsat,
    tryMsatToSat,
    trySatToMsatT,
    tryMsatToSatT,
    trxDustLimit,
    trxHeadSize,
    trxInSize,
    trxOutSize,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Network.Bitcoin as Btc
import qualified Universum

roundWord64ToMSat :: (Real a) => a -> MSat
roundWord64ToMSat amt =
  MSat
    . (* 1000)
    . fromInteger
    $ ceiling (toRational amt / 1000)

--
-- TODO : replace Btc.BTC type alias with newtype
-- and then inplement TryFrom BTC MSat and TryFrom MSat BTC,
-- then remove these combinators, they will be available
-- for free.
--

trySatToMsat ::
  Btc.BTC ->
  Either Failure MSat
trySatToMsat =
  first (FailureTryFrom . Universum.show)
    . ( from @Word64
          `composeTryRhs` tryFrom @Integer
            `composeTryLhs` ((* 1000) . from)
      )

tryMsatToSat ::
  MSat ->
  Either Failure Btc.BTC
tryMsatToSat =
  first (FailureTryFrom . Universum.show)
    . ( tryFrom @Rational @Btc.BTC
          `composeTryLhs` ((% 100000000000) . via @Word64)
      )

trySatToMsatT ::
  ( Monad m
  ) =>
  Btc.BTC ->
  ExceptT Failure m MSat
trySatToMsatT =
  except . trySatToMsat

tryMsatToSatT ::
  ( Monad m
  ) =>
  MSat ->
  ExceptT Failure m Btc.BTC
tryMsatToSatT =
  except . tryMsatToSat

trxDustLimit :: MSat
trxDustLimit =
  MSat $ 546 * 1000

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
