{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Yesod.Data.Widget where

import BtcLsp.Yesod.Import
import GHC.Exts (IsList (..))
import Yesod.Form.Bootstrap3

newtype HtmlClassAttr = HtmlClassAttr {unHtmlClassAttr :: [Text]}
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Semigroup,
      Monoid
    )
  deriving stock
    ( Generic
    )

instance Out HtmlClassAttr

instance IsList HtmlClassAttr where
  type Item HtmlClassAttr = Text
  fromList = HtmlClassAttr
  toList = unHtmlClassAttr

--
-- TODO : use bootstrap tabs/panels to provide
-- basic and advanced view options for users.
--
data Layout
  = BasicLayout
  | AdvancedLayout
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic,
      Enum,
      Bounded
    )

instance Out Layout

bfsAutoFocus :: RenderMessage site msg => msg -> FieldSettings site
bfsAutoFocus msg =
  bfsStandard {fsAttrs = ("autofocus", "") : fsAttrs bfsStandard}
  where
    bfsStandard = bfs msg

bfsDisabled :: RenderMessage site msg => msg -> FieldSettings site
bfsDisabled msg =
  bfsStandard {fsAttrs = ("disabled", "") : fsAttrs bfsStandard}
  where
    bfsStandard = bfs msg

fromTextField ::
  forall m a.
  ( Monad m,
    From Text a,
    From a Text,
    'False ~ (Text == a),
    'False ~ (a == Text),
    RenderMessage (HandlerSite m) FormMessage
  ) =>
  Field m a
fromTextField =
  Field
    { fieldParse = \f xs ->
        ((from <$>) <$>) <$> fieldParse txtField f xs,
      fieldView = \theId fieldName attrs val isReq ->
        fieldView
          txtField
          theId
          fieldName
          attrs
          (from <$> val)
          isReq,
      fieldEnctype =
        fieldEnctype txtField
    }
  where
    txtField :: Field m Text
    txtField = textField

newListWidget ::
  [[(AppMessage, AppMessage)]] ->
  Maybe Widget
newListWidget =
  newGenListWidget Nothing $ 1 % 2

newNamedListWidget ::
  AppMessage ->
  [[(AppMessage, AppMessage)]] ->
  Maybe Widget
newNamedListWidget title =
  newGenListWidget (Just title) $ 1 % 3

newGenListWidget ::
  Maybe AppMessage ->
  Rational ->
  [[(AppMessage, AppMessage)]] ->
  Maybe Widget
newGenListWidget _ _ [] =
  Nothing
newGenListWidget mTitle colProp rawRows =
  Just $(widgetFile "named_list")
  where
    idxRows :: [(Natural, [(AppMessage, AppMessage)])]
    idxRows = zip [0 ..] rawRows
    c1 :: Integer
    c1 = round $ 12 * colProp
    c2 :: Integer
    c2 = 12 - c1
