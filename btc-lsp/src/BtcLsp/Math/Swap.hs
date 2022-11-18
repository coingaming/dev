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
  Money $ Msat 10000000000

swapLnFeeRate :: FeeRate
swapLnFeeRate =
  FeeRate 0.004

swapLnMinFee :: Money 'Lsp btcl 'Gain
swapLnMinFee =
  Money $ Msat 2000000

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
              swapCapFee = from @Natural $ ceiling feeRat
            }
  where
    usrFin :: Ratio Natural
    usrFin =
      from usrAmt % 1
    feeRat :: Ratio Natural
    feeRat =
      from @Natural
        . (* 1000)
        . ceiling
        . (/ 1000)
        . max (from swapLnMinFee % 1)
        $ usrFin * unFeeRate swapLnFeeRate
    usrLn :: Money 'Usr 'Ln 'Fund
    usrLn =
      from @Natural
        . floor
        $ usrFin - feeRat

newSwapIntoLnMinAmt ::
  Money 'Chan 'Ln 'Fund ->
  Money 'Usr 'OnChain 'Fund
newSwapIntoLnMinAmt minCap =
  from @Natural
    . (* 1000)
    . ceiling
    $ usrInitMsat / 1000
  where
    minFee :: Ratio Natural
    minFee =
      from swapLnMinFee % 1
    usrFin :: Ratio Natural
    usrFin =
      from minCap % 2
    usrPerc :: Ratio Natural
    usrPerc =
      usrFin / (1 - unFeeRate swapLnFeeRate)
    usrInitMsat :: Ratio Natural
    usrInitMsat =
      if usrPerc - usrFin >= minFee
        then usrPerc
        else usrFin + minFee
