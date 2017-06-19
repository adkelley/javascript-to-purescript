module Example5 (wrapExample) where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION, try)
import Data.Either (either)
import Data.Example (getPreviewPath)
import Data.Foreign (Foreign, unsafeFromForeign)
import Data.Utils (assignObject2, chain, fromNullable, parseValue)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)


wrapExample :: forall eff. Foreign -> Eff (fs :: FS, exception :: EXCEPTION | eff) Foreign
wrapExample example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  either (\_ -> pure example) wrapExample'
  where
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      chain parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure
