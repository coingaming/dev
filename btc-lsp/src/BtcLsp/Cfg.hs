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
    $ from @FeeRate @(Ratio Natural) swapLnFeeRate * from amt of
    Right fee ->
      max fee swapLnMinFee
    Left err ->
      error $
        "Impossible newSwapIntoLnFee "
          <> Universum.show err
