{-# LANGUAGE TypeApplications #-}

module BtcLsp.Math
  ( SwapCap,
    swapCapUsr,
    swapCapLsp,
    swapCapFee,
    swapLnMinAmt,
    swapLnMaxAmt,
    swapLnFeeRate,
    swapLnMinFee,
    newSwapCap,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Universum

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

swapLnMinAmt :: Money 'Usr btcl 'Fund
swapLnMinAmt =
  Money $ MSat 10000000

swapLnMaxAmt :: Money 'Usr btcl 'Fund
swapLnMaxAmt =
  Money $ MSat 10000000000

swapLnFeeRate :: FeeRate
swapLnFeeRate =
  FeeRate 0.004

swapLnMinFee :: Money 'Lsp btcl 'Gain
swapLnMinFee =
  Money $ MSat 2000000

newSwapCap ::
  Money 'Usr 'OnChain 'Fund ->
  Maybe SwapCap
newSwapCap usrCh =
  if usrCh < swapLnMinAmt
    then Nothing
    else
      Just
        SwapCap
          { swapCapUsr = usrLn,
            swapCapLsp = coerce usrLn,
            swapCapFee = fee
          }
  where
    fee =
      newSwapFee usrCh
    usrLn =
      coerce $
        usrCh - coerce fee

newSwapFee ::
  Money 'Usr 'OnChain 'Fund ->
  Money 'Lsp 'OnChain 'Gain
newSwapFee amt =
  case tryFrom @Natural
    . round
    --
    -- NOTE : we are using Rational instead of
    -- Ratio Natural because of GHC-related issue
    -- https://gist.github.com/tim2CF/e63c7ff792e26362f356e71c47319494
    -- After report to GHC bug tracker seems like
    -- we need to upgrade to latest GHC where issue is fixed:
    -- https://gitlab.haskell.org/ghc/ghc/-/issues/21004
    --
    $ from @FeeRate @Rational swapLnFeeRate
      * from amt of
    Right fee ->
      max fee swapLnMinFee
    Left err ->
      error $
        "Impossible newSwapFee "
          <> Universum.show err
