module Example4 (concatUniq) where

import Prelude
import Data.String.Utils (filter)
import Data.Either (Either(..), either)

fromEmptyString :: String -> Either String String
fromEmptyString value =
  if (value == "")
    then Left value
    else Right value

concatUniq :: String -> String -> String
concatUniq x ys =
  filter (\y -> y == x) ys #
  fromEmptyString #
  either (\_ -> ys <> x) (\_ -> ys)
