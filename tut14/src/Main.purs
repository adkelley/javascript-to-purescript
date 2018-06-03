module Main where

import Prelude

import Data.Box (Box(..))
import Effect (Effect)
import Effect.Console (log, logShow)

foreign import toUpperCase :: String -> String
-- ignores that substr takes an optional length argument
foreign import substrImpl :: Int -> String -> String

-- First law of Functors
-- fx.map(f).map(g) == fx.map(x => g(f(x)))
res1 :: Box String
res1 =
  Box "squirrels"
  # map (\str -> substrImpl 5 str)
  # map toUpperCase

res2 :: Box String
res2 =
  Box "Squirrels"
  # map (\str -> toUpperCase (substrImpl 5 str))

-- Second law of Functors
-- fx.map(id) == id(fx)
res3 :: Box String
res3 =
  Box "crayons"
  # map identity

res4 :: Box String
res4 =
  identity (Box "crayons")

main :: Effect Unit
main = do
  log "You've been using Functors"
  logShow $ res1
  logShow $ res2
  logShow $ res3
  logShow $ res4
