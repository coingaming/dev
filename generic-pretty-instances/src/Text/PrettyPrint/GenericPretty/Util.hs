module Text.PrettyPrint.GenericPretty.Util
  ( log,
    logStr,
    logGen,
    logStyle,
    logStyleStr,
    logStyleGen,
  )
where

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Text.Pretty.Simple as PrettySimple
import qualified Text.PrettyPrint as Pretty
import Text.PrettyPrint.GenericPretty (Out)
import qualified Text.PrettyPrint.GenericPretty as GenericPretty
import Universum hiding (show)

log :: (Out a) => a -> T.Text
log =
  logStyle simpleStyle

logStr :: (Out a) => a -> String
logStr =
  logStyleStr simpleStyle

logGen :: (Out a, IsString b) => a -> b
logGen =
  logStyleGen simpleStyle

logStyle ::
  (Out a) =>
  PrettySimple.OutputOptions ->
  a ->
  T.Text
logStyle style =
  TL.toStrict
    . PrettySimple.pStringOpt style
    . GenericPretty.prettyStyle
      Pretty.style
        { Pretty.mode = Pretty.OneLineMode
        }

logStyleStr ::
  (Out a) =>
  PrettySimple.OutputOptions ->
  a ->
  String
logStyleStr style =
  T.unpack . logStyle style

logStyleGen ::
  ( Out a,
    IsString b
  ) =>
  PrettySimple.OutputOptions ->
  a ->
  b
logStyleGen style =
  fromString . logStyleStr style

simpleStyle :: PrettySimple.OutputOptions
simpleStyle =
  PrettySimple.defaultOutputOptionsDarkBg
