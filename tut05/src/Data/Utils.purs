module Data.Utils (chain, fromNullable) where

import Prelude
import Data.Either (Either(..), either)
import Data.Foreign (Foreign, isNull, isUndefined)

fromNullable :: Foreign -> Either Foreign Foreign
fromNullable value =
  if (isNull value || isUndefined value)
   then Left value
   else Right value

chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f  = either (\e -> Left e) (\x -> (f x))
