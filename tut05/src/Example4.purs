module Example4 (concatUniq) where

import Prelude
import Data.String.Utils (filter)
import Data.Either (either)
import Data.Utils (fromEmptyString)

concatUniq :: String -> String -> String
concatUniq x ys =
  filter (\y -> y == x) ys #
  fromEmptyString #
  either (\_ -> ys <> x) (\_ -> ys)
