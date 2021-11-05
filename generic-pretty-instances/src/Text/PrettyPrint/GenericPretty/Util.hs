module Text.PrettyPrint.GenericPretty.Util
  ( inspect,
    inspectStr,
    inspectGen,
    inspectStyle,
    inspectStyleStr,
    inspectStyleGen,
  )
where

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Text.Pretty.Simple as PrettySimple
import qualified Text.PrettyPrint as Pretty
import Text.PrettyPrint.GenericPretty (Out)
import qualified Text.PrettyPrint.GenericPretty as GenericPretty
import Universum hiding (show)

inspect :: (Out a) => a -> T.Text
inspect =
  inspectStyle simpleStyle

inspectStr :: (Out a) => a -> String
inspectStr =
  inspectStyleStr simpleStyle

inspectGen :: (Out a, IsString b) => a -> b
inspectGen =
  inspectStyleGen simpleStyle

inspectStyle ::
  (Out a) =>
  PrettySimple.OutputOptions ->
  a ->
  T.Text
inspectStyle style =
  TL.toStrict
    . PrettySimple.pStringOpt style
    . GenericPretty.prettyStyle
      Pretty.style
        { Pretty.mode = Pretty.OneLineMode
        }

inspectStyleStr ::
  (Out a) =>
  PrettySimple.OutputOptions ->
  a ->
  String
inspectStyleStr style =
  T.unpack . inspectStyle style

inspectStyleGen ::
  ( Out a,
    IsString b
  ) =>
  PrettySimple.OutputOptions ->
  a ->
  b
inspectStyleGen style =
  fromString . inspectStyleStr style

simpleStyle :: PrettySimple.OutputOptions
simpleStyle =
  PrettySimple.defaultOutputOptionsDarkBg
