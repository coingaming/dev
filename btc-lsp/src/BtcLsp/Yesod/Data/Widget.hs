{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Data.Widget where

import BtcLsp.Yesod.Data.Colored
import BtcLsp.Yesod.Import
import Colonnade
import qualified Data.Text as T
import GHC.Exts (IsList (..))
import Text.Blaze.Html5.Attributes hiding
  ( rows,
    title,
  )
import Yesod.Colonnade
import Yesod.Form.Bootstrap3

newtype HtmlClassAttr
  = HtmlClassAttr [Text]
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
  fromList = coerce
  toList = coerce

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

makeTableWidget ::
  (Foldable f, Headedness h) =>
  Colonnade h a (Cell site) ->
  f a ->
  WidgetFor site ()
makeTableWidget =
  encodeCellTable
    [ class_
        "table table-bordered table-condensed text-left align-middle"
    ]

widgetCol ::
  (Colored b, ToWidget site a) =>
  a ->
  (Entity b -> WidgetFor site ()) ->
  Colonnade Headed (Entity b) (Cell site)
widgetCol headerLabel renderer =
  headed (Cell [] (toWidget headerLabel)) (\x -> Cell (cellAttributes x) (renderer x))
  where
    cellAttributes x =
      case (color . entityVal) x of
        Just bsColor -> [class_ $ fromString $ toLower $ show bsColor]
        Nothing -> []

textCol ::
  ( ToWidget site a1,
    ToWidget site a2,
    Colored b
  ) =>
  a1 ->
  (b -> a2) ->
  Colonnade Headed b (Cell site)
textCol =
  textColClass mempty

textColClass ::
  ( ToWidget site a1,
    ToWidget site a2,
    Colored b
  ) =>
  HtmlClassAttr ->
  a1 ->
  (b -> a2) ->
  Colonnade Headed b (Cell site)
textColClass classAttr headerLabel renderer =
  headed
    (Cell [] (toWidget headerLabel))
    (\x -> Cell (cellAttributes x) (toWidget $ renderer x))
  where
    cellAttributes x =
      if null xs
        then mempty
        else
          pure
            . class_
            . fromString
            . unpack
            $ T.intercalate " " xs
      where
        xs =
          coerce classAttr
            <> maybe mempty (pure . bsColor2Class) (color x)

textColHiddenXs ::
  ( ToWidget site a1,
    ToWidget site a2,
    Colored b
  ) =>
  a1 ->
  (b -> a2) ->
  Colonnade Headed b (Cell site)
textColHiddenXs headerLabel renderer =
  headed
    (Cell [class_ "hidden-xs"] (toWidget headerLabel))
    (\x -> Cell (cellAttributes x) (toWidget $ renderer x))
  where
    cellAttributes x =
      case color x of
        Just bsColor ->
          [ class_
              . fromString
              . toLower
              $ "hidden-xs " ++ show bsColor
          ]
        Nothing ->
          [class_ "hidden-xs"]

updateCol ::
  Colored b =>
  (Entity b -> Route site) ->
  Colonnade Headed (Entity b) (Cell site)
updateCol updateResolver =
  headed (textCell "") (\x -> Cell (cellAttributes x) (colWidget x))
  where
    cellAttributes x =
      case (color . entityVal) x of
        Just bsColor -> [class_ $ fromString $ toLower $ show bsColor]
        Nothing -> []
    colWidget x =
      [whamlet|
        <div .show>
          <a .btn.btn-warning.btn-sm href=@{updateResolver x}>
            <span .glyphicon.glyphicon-pencil aria-hidden="true">
      |]

updateShowCol ::
  Colored b =>
  (Entity b -> Route site) ->
  (Entity b -> Route site) ->
  Colonnade Headed (Entity b) (Cell site)
updateShowCol updateResolver showResolver =
  headed (textCell "") (\x -> Cell (cellAttributes x) (colWidget x))
  where
    cellAttributes x =
      case (color . entityVal) x of
        Just bsColor -> [class_ $ fromString $ toLower $ show bsColor]
        Nothing -> []
    colWidget x =
      [whamlet|
        <div .show>
          <a .btn.btn-warning.btn-sm href=@{updateResolver x}>
            <span .glyphicon.glyphicon-pencil aria-hidden="true">
        <div .show.small-margin-top>
          <a .btn.btn-info.btn-sm href=@{showResolver x}>
            <span .glyphicon.glyphicon-eye-open aria-hidden="true">
      |]

updateDeleteCol ::
  Colored b =>
  (Entity b -> Route site) ->
  (Entity b -> Route site) ->
  Colonnade Headed (Entity b) (Cell site)
updateDeleteCol updateResolver deleteResolver =
  headed (textCell "") (\x -> Cell (cellAttributes x) (colWidget x))
  where
    cellAttributes x =
      case (color . entityVal) x of
        Just bsColor -> [class_ $ fromString $ toLower $ show bsColor]
        Nothing -> []
    colWidget x =
      [whamlet|
        <div .show>
          <a .btn.btn-warning.btn-sm href=@{updateResolver x}>
            <span .glyphicon.glyphicon-pencil aria-hidden="true">
        <div .show.small-margin-top>
          <a .btn.btn-danger.btn-sm href=@{deleteResolver x}>
            <span .glyphicon.glyphicon-trash aria-hidden="true">
      |]

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

toText ::
  ( From a Text,
    'False ~ (Text == a),
    'False ~ (a == Text)
  ) =>
  a ->
  Text
toText =
  from

newNamedListWidget ::
  AppMessage ->
  [[(AppMessage, Text)]] ->
  Maybe Widget
newNamedListWidget _ [] =
  Nothing
newNamedListWidget title rows =
  Just $(widgetFile "named_list")
