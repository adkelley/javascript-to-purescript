module Example5 (wrapExample, wrapExample_) where

import Prelude

import Effect (Effect)
import Effect.Exception (try)
import Data.Either (Either(..), either)
import Data.Example (getPreviewPath)
import Foreign (Foreign, unsafeFromForeign)
import Data.Utils (assignObject2, fromNullable, parseValue)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)


wrapExample :: Foreign -> Effect Foreign
wrapExample example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  either (\_ -> pure example) wrapExample'
  where
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      either Left parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure

wrapExample_ :: Foreign -> Effect Foreign
wrapExample_ example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  let
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      either Left parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure
  in
    either (\_ -> pure example) wrapExample'
