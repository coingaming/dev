{-# LANGUAGE TypeApplications #-}

module BtcLsp.Cfg
  ( swapLnFeeRate,
    swapLnMinFee,
    newChanCapLsp,
    newSwapIntoLnFee,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Universum

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
    -- TODO : open issue in GHC tracker.
    -- Here we are forced to use Rational
    -- instead or Ratio Natural because of this
    --
    -- https://gist.github.com/tim2CF/e63c7ff792e26362f356e71c47319494
    --
    $ from @FeeRate @Rational swapLnFeeRate
      * from amt of
    Right fee ->
      max fee swapLnMinFee
    Left err ->
      error $
        "Impossible newSwapIntoLnFee "
          <> Universum.show err
