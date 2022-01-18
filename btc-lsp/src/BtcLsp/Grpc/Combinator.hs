{-# LANGUAGE TypeApplications #-}

module BtcLsp.Grpc.Combinator
  ( fromReqT,
    fromReqE,
    failResE,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Import.External
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import qualified Proto.BtcLsp.Data.HighLevel as Proto

fromReqT ::
  forall a b m.
  ( Monad m,
    From a b,
    'False ~ (a == b)
  ) =>
  Maybe a ->
  ExceptT Failure m b
fromReqT =
  except
    . fromReqE

fromReqE ::
  forall a b.
  ( From a b,
    'False ~ (a == b)
  ) =>
  Maybe a ->
  Either Failure b
fromReqE =
  (from <$>)
    . maybeToRight
      --
      -- TODO : replace with real error
      --
      (FailureInput [defMessage])

failResE ::
  ( HasField res "failure" failure,
    HasField failure "input" [Proto.InputFailure],
    HasField failure "internal" [internal],
    Message res,
    Message failure,
    Message internal
  ) =>
  Failure ->
  res
failResE = \case
  FailureInput es ->
    defMessage
      & field @"failure"
        .~ ( defMessage
               & field @"input" .~ es
           )
  _ ->
    defMessage
      & field @"failure"
        .~ ( defMessage
               & field @"internal"
                 .~ [defMessage]
           )
