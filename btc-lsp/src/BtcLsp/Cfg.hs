{-# LANGUAGE TypeApplications #-}

module BtcLsp.Cfg
  ( swapLnMinAmt,
    swapLnMaxAmt,
    swapLnFeeRate,
    swapLnMinFee,
    newChanCapLsp,
    newSwapIntoLnFee,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Universum

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

newChanCapLsp ::
  Money 'Usr 'Ln 'Fund ->
  Money 'Lsp 'Ln 'Fund
newChanCapLsp =
  coerce

newSwapIntoLnFee ::
  Money 'Usr 'Ln 'Fund ->
  Money 'Lsp 'OnChain 'Gain
newSwapIntoLnFee amt =
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
        "Impossible newSwapIntoLnFee "
          <> Universum.show err
