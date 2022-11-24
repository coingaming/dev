module Text.PrettyPrint.GenericPretty.Class
  ( GenericPrettyEnv (..),
  )
where

import qualified Text.Pretty.Simple as PrettySimple
import Text.PrettyPrint.GenericPretty (Out)
import qualified Text.PrettyPrint.GenericPretty.Type as Type
import qualified Text.PrettyPrint.GenericPretty.Util as Util
import Universum hiding (show)

class (MonadIO m) => GenericPrettyEnv m where
  getStyle :: m PrettySimple.OutputOptions
  getStyle =
    pure PrettySimple.defaultOutputOptionsDarkBg
  getSecretVision :: m Type.SecretVision
  getSecretVision =
    pure Type.SecretHidden
  getInspect :: forall b a. (Out a, IsString b) => m (a -> b)
  getInspect =
    Util.inspectStyle <$> getStyle
  getInspectSecret :: forall b a. (Out a, IsString b) => m (a -> b)
  getInspectSecret = do
    secretVision <- getSecretVision
    case secretVision of
      Type.SecretVisible -> getInspect
      Type.SecretHidden -> pure $ const "<REDACTED>"
  inspectM :: forall b a. (Out a, IsString b) => a -> m b
  inspectM x =
    ($ x) <$> getInspect
  inspectSecretM :: forall b a. (Out a, IsString b) => a -> m b
  inspectSecretM x =
    ($ x) <$> getInspectSecret
