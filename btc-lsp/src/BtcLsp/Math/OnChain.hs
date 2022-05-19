module BtcLsp.Math.OnChain
  ( roundWord64ToMSat,
    trxDustLimit,
    trxHeadSize,
    trxInSize,
    trxOutSize,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Import.External

roundWord64ToMSat :: (Real a) => a -> MSat
roundWord64ToMSat amt =
  MSat
    . (* 1000)
    . fromInteger
    $ ceiling (toRational amt / 1000)

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
