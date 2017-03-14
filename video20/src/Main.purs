module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.List (List(..), (:))

-- pure = List.of()
merch :: List String
merch =
  pure (\x y z -> x <> "-" <> y <> "-" <> z)
  `apply` ("teeshirt" : "sweater" : Nil)
  `apply` ("large" : "medium" : "small" : Nil)
  `apply` ("black" : "white" : Nil)

result1 :: List Int
result1 = pure (\x -> x) `apply` (1 : 2 : 3 : Nil)

result2 :: List String
result2 = merch

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "List comprehensions with Applicative Functors"
  logShow $ result1
  logShow $ result2
