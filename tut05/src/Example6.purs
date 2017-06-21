module Example6 (parseDbUrl, parseDbUrl_) where

import Prelude

import Control.Monad.Eff.Exception (Error, error)
import Data.Array (singleton)
import Data.Either (Either(..), either)
import Data.Example (getDbUrl)
import Data.Foreign (unsafeFromForeign)
import Data.Maybe (Maybe(..))
import Data.String.Regex (Regex, match, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Utils (fromNullable, parseValue, chain)
import Partial.Unsafe (unsafePartial)

dBUrlRegex :: Partial => Regex
dBUrlRegex =
  unsafePartial
    case regex "^postgres:\\/\\/([a-z]+):([a-z]+)@([a-z]+)\\/([a-z]+)$" noFlags of
      Right r -> r

matchUrl :: Regex -> String -> Either Error (Array (Maybe String))
matchUrl r url =
  case match r url of
    Nothing -> Left $ error "unmatched url"
    Just x -> Right x

parseDbUrl_ :: Partial => String -> Array (Maybe String)
parseDbUrl_ =
  parseValue >>>
  chain (\config -> fromNullable $ getDbUrl config) >>>
  map (\url -> unsafeFromForeign url :: String) >>>
  chain (matchUrl dBUrlRegex) >>>
  either (\_ -> singleton Nothing) id

parseDbUrl :: Partial => String -> Array (Maybe String)
parseDbUrl s =
  (parseValue s) >>=
  (\config -> fromNullable $ getDbUrl config) >>>
  map (\url -> unsafeFromForeign url :: String) >>=
  (\r -> matchUrl dBUrlRegex r) #
  either (\_ -> singleton Nothing) id
