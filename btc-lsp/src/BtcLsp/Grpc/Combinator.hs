{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Grpc.Combinator
  ( fromReqT,
    fromReqE,
    newGenFailure,
    newSpecFailure,
    newInternalFailure,
    throwSpec,
    mkFieldLocation,
    GrpcReq,
    GrpcRes,
  )
where

import BtcLsp.Import.External as Ext
import Data.Map as Map
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import Data.Text as T
import Language.Haskell.TH.Syntax as TH
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Universum
import qualified Witch

type GrpcReq req =
  ( HasField req "maybe'ctx" (Maybe Proto.Ctx)
  )

type GrpcRes res failure specific internal =
  ( HasField res "ctx" Proto.Ctx,
    HasField res "failure" failure,
    HasField failure "generic" [Proto.InputFailure],
    HasField failure "specific" [specific],
    HasField failure "internal" [internal],
    Message res,
    Message failure,
    Message internal
  )

fromReqT ::
  forall a b res failure specific internal m.
  ( From a b,
    'False ~ (a == b),
    GrpcRes res failure specific internal,
    Monad m
  ) =>
  ReversedFieldLocation ->
  Maybe a ->
  ExceptT res m b
fromReqT loc =
  except
    . fromReqE loc

fromReqE ::
  forall a b res failure specific internal.
  ( From a b,
    'False ~ (a == b),
    GrpcRes res failure specific internal
  ) =>
  ReversedFieldLocation ->
  Maybe a ->
  Either res b
fromReqE loc =
  (from <$>)
    . maybeToRight msg
  where
    msg =
      defMessage
        & field @"failure"
          .~ ( defMessage
                 & field @"generic"
                   .~ [ defMessage
                          & Proto.fieldLocation .~ from loc
                          & Proto.kind .~ Proto.REQUIRED
                      ]
             )

newGenFailure ::
  forall res failure specific internal.
  ( GrpcRes res failure specific internal
  ) =>
  Proto.InputFailureKind ->
  ReversedFieldLocation ->
  res
newGenFailure kind loc =
  defMessage
    & field @"failure"
      .~ ( defMessage
             & field @"generic"
               .~ [ defMessage
                      & Proto.fieldLocation .~ from loc
                      & Proto.kind .~ kind
                  ]
         )

newSpecFailure ::
  forall res failure specific internal.
  ( GrpcRes res failure specific internal
  ) =>
  specific ->
  res
newSpecFailure spec =
  defMessage
    & field @"failure"
      .~ ( defMessage
             & field @"specific"
               .~ [ spec
                  ]
         )

newInternalFailure ::
  forall res failure specific internal.
  ( GrpcRes res failure specific internal
  ) =>
  internal ->
  res
newInternalFailure int =
  defMessage
    & field @"failure"
      .~ ( defMessage
             & field @"internal"
               .~ [ int
                  ]
         )

throwSpec ::
  forall a res failure specific internal m.
  ( GrpcRes res failure specific internal,
    Monad m
  ) =>
  specific ->
  ExceptT res m a
throwSpec =
  throwE . newSpecFailure

--
-- TH FieldIndex combinators
--

newtype FieldIndex
  = FieldIndex Word32
  deriving newtype
    ( Eq,
      Ord,
      Show
    )
  deriving stock
    ( TH.Lift
    )

newtype ReversedFieldLocation
  = ReversedFieldLocation [FieldIndex]
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Semigroup,
      Monoid
    )
  deriving stock
    ( TH.Lift
    )

instance From ReversedFieldLocation [Proto.FieldIndex] where
  from (ReversedFieldLocation xs) =
    ( \x ->
        defMessage
          & Proto.val .~ coerce x
    )
      <$> Ext.reverse xs

mkFieldLocation ::
  forall a.
  ( Message a
  ) =>
  [String] ->
  Q Exp
mkFieldLocation ns =
  [|
    $(mkPushFieldIndexes @a ns) $
      ReversedFieldLocation []
    |]

mkPushFieldIndexes ::
  forall a.
  ( Message a
  ) =>
  [String] ->
  Q Exp
mkPushFieldIndexes ns = do
  addLoc <- getFieldLocation @a ns
  [|(<>) $(TH.lift addLoc)|]

getFieldLocation ::
  forall a m.
  ( Message a,
    MonadFail m
  ) =>
  [String] ->
  m ReversedFieldLocation
getFieldLocation =
  (ReversedFieldLocation <$>)
    . getFieldLocation0 @a []

getFieldLocation0 ::
  forall a m.
  ( Message a,
    MonadFail m
  ) =>
  [FieldIndex] ->
  [String] ->
  m [FieldIndex]
getFieldLocation0 acc0 [] = pure acc0
getFieldLocation0 acc0 (n : ns) =
  case Ext.find ((\(FieldDescriptor x _ _) -> x == n) . snd) $
    Map.toList (fieldsByTag :: Map Tag (FieldDescriptor a)) of
    Just (_, FieldDescriptor _ _ MapField {}) ->
      fieldFail
        "is MapField (not supported by current TH combinators)"
    Just (_, FieldDescriptor _ _ RepeatedField {})
      | not (Ext.null ns) ->
        fieldFail
          "is RepeatedField and not last field in TH splice"
    Just (it, FieldDescriptor _ ftd _) -> do
      acc <- case tryFrom $ unTag it of
        Right x -> pure $ FieldIndex x : acc0
        Left e ->
          fieldFail $
            "tag overflow "
              <> Universum.show e
              <> " of "
              <> Universum.show it
      case ftd of
        (MessageField {} :: FieldTypeDescriptor nextA) ->
          getFieldLocation0 @nextA acc ns
        ScalarField {} ->
          if Ext.null ns
            then pure acc
            else
              fieldFail $
                "scalar got extra tags "
                  <> inspectStr ns
    Nothing ->
      fieldFail "not found"
  where
    msgName =
      T.unpack $
        messageName (Proxy :: Proxy a)
    fieldFail x =
      fail $
        "Field " <> n <> " of " <> msgName <> " " <> x
