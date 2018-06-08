module Example4 (concatUniq) where

import Prelude

import Data.Array as Array
import Data.Either (either)
import Data.String.CodeUnits (fromCharArray, singleton, toCharArray)
import Data.Utils (fromEmptyString)

-- | Borrowed from Data.String.Utils
filter_ :: (Char -> Boolean) -> String -> String
filter_ p = fromCharArray <<< Array.filter p <<< toCharArray

concatUniq :: Char -> String -> String
concatUniq x ys =
  filter_ (_ == x) ys #
  fromEmptyString #
  either (\_ -> ys <> (singleton x)) \_ -> ys
