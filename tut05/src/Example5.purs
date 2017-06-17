module Example5 (wrapExample) where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION, Error, try)
import Data.Either (Either, either)
import Data.Example (getPreviewPath)
import Data.Foreign (Foreign, unsafeFromForeign)
import Data.Utils (chain, fromNullable)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)

-- readFile :: forall eff. String -> Eff (fs :: FS, exception :: EXCEPTION | eff) (Either Error String)
-- readFile pathToFile =
--   try $ readTextFile UTF8 pathToFile

-- wrapExample :: Foreign -> String
-- wrapExample example =
--   fromNullable (getPreviewPath example) #
--   -- chain (\path -> readFile $ unsafeFromForeign path :: String) >>=
--   chain (\path -> readFile $ ?hole) >>=
--   either (\_ -> "no example") (\path -> unsafeFromForeign path :: String) #
--   pure

wrapExample :: Foreign -> String
wrapExample example = "stub"
