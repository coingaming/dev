{-# LANGUAGE TypeApplications #-}

module BtcLsp.Math.Swap
  ( SwapCap (..),
    swapExpiryLimitInput,
    swapExpiryLimitInternal,
    swapLnMaxAmt,
    swapLnFeeRate,
    swapLnMinFee,
    newSwapCapM,
    newSwapIntoLnMinAmt,
  )
where

import BtcLsp.Class.Env
import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified LndClient as Lnd

data SwapCap = SwapCap
  { swapCapUsr :: Money 'Usr 'Ln 'Fund,
    swapCapLsp :: Money 'Lsp 'Ln 'Fund,
    swapCapFee :: Money 'Lsp 'OnChain 'Gain
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out SwapCap

swapExpiryLimitInput :: Lnd.Seconds
swapExpiryLimitInput =
  Lnd.Seconds $ (7 * 24 - 1) * 3600

swapExpiryLimitInternal :: Lnd.Seconds
swapExpiryLimitInternal =
  Lnd.Seconds 3600

swapLnMaxAmt :: Money 'Usr btcl 'Fund
swapLnMaxAmt =
  Money $ MSat 10000000000

swapLnFeeRate :: FeeRate
swapLnFeeRate =
  FeeRate 0.004

swapLnMinFee :: Money 'Lsp btcl 'Gain
swapLnMinFee =
  Money $ MSat 2000000

newSwapCapM ::
  ( Env m
  ) =>
  Money 'Usr 'OnChain 'Fund ->
  m (Maybe SwapCap)
newSwapCapM usrAmt = do
  minAmt <- getSwapIntoLnMinAmt
  pure $
    if usrAmt < minAmt
      then Nothing
      else
        Just
          SwapCap
            { swapCapUsr = usrLn,
              swapCapLsp = coerce usrLn,
              swapCapFee = from @Word64 $ ceiling feeRat
            }
  where
    usrFin :: Ratio Word64
    usrFin =
      from usrAmt % 1
    feeRat :: Ratio Word64
    feeRat =
      from @Word64
        . (* 1000)
        . ceiling
        . (/ 1000)
        . max (from swapLnMinFee % 1)
        $ usrFin * from swapLnFeeRate
    usrLn :: Money 'Usr 'Ln 'Fund
    usrLn =
      from @Word64
        . floor
        $ usrFin - feeRat

newSwapIntoLnMinAmt ::
  Money 'Chan 'Ln 'Fund ->
  Money 'Usr 'OnChain 'Fund
newSwapIntoLnMinAmt minCap =
  from @Word64
    . (* 1000)
    . ceiling
    $ usrInitMsat / 1000
  where
    minFee :: Ratio Word64
    minFee =
      from swapLnMinFee % 1
    usrFin :: Ratio Word64
    usrFin =
      from minCap % 2
    usrPerc :: Ratio Word64
    usrPerc =
      usrFin / (1 - from swapLnFeeRate)
    usrInitMsat :: Ratio Word64
    usrInitMsat =
      if usrPerc - usrFin >= minFee
        then usrPerc
        else usrFin + minFee
