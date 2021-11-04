module Text.PrettyPrint.GenericPretty.Util
  ( show,
    showStr,
    showGen,
    showStyle,
    showStyleStr,
    showStyleGen,
  )
where

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Text.Pretty.Simple as PrettySimple
import qualified Text.PrettyPrint as Pretty
import Text.PrettyPrint.GenericPretty (Out)
import qualified Text.PrettyPrint.GenericPretty as GenericPretty
import Universum hiding (show)

show :: (Out a) => a -> T.Text
show =
  showStyle Pretty.style

showStr :: (Out a) => a -> String
showStr =
  showStyleStr Pretty.style

showGen :: (Out a, IsString b) => a -> b
showGen =
  showStyleGen Pretty.style

showStyle :: (Out a) => Pretty.Style -> a -> T.Text
showStyle style =
  TL.toStrict
    . PrettySimple.pString
    . GenericPretty.prettyStyle style

showStyleStr :: (Out a) => Pretty.Style -> a -> String
showStyleStr style =
  T.unpack . showStyle style

showStyleGen :: (Out a, IsString b) => Pretty.Style -> a -> b
showStyleGen style =
  fromString . showStyleStr style
