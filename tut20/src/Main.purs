module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log, logShow)
import Data.List (List(..), (:))

-- pure ~ List.of() in JavaScript
merch :: List String
merch =
  pure (\x y z -> x <> "-" <> y <> "-" <> z)
  <*> ("teeshirt" : "sweater" : Nil)
  <*> ("large" : "medium" : "small" : Nil)
  <*> ("black" : "white" : Nil)

result1 :: List Int
result1 = pure (\x -> x) <*> (1 : 2 : 3 : Nil)

result2 :: List String
result2 = merch

main :: Effect Unit
main = do
  log "List comprehensions with Applicative Functors"
  logShow $ result1
  logShow $ result2
