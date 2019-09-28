module Main where

import Prelude

import Data.Array (fromFoldable)
import Data.List (List(..), (:))
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log, logShow)

listToArray :: forall a. List a -> Array a
listToArray = fromFoldable

main :: Effect Unit
main = do
  log "Hello sailor!"
  logShow $ (listToArray ("hello" : "world" : Nil)) >>= \x -> split (Pattern "") x
