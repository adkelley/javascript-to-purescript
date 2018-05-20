module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Box (Box(..))

foreign import toUpperCase :: String -> String
-- ignores that substr takes an optional length argument
foreign import substrImpl :: Int -> String -> String

-- First law of Functors
-- fx.map(f).map(g) == fx.map(x => g(f(x)))
res1 :: Box String
res1 =
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
  # map id

res4 :: Box String
res4 =
  id (Box "crayons")

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "You've been using Functors"
  logShow $ res1
  logShow $ res2
  logShow $ res3
  logShow $ res4
