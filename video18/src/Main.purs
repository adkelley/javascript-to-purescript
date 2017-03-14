module Main where

import Prelude
import Control.Apply (lift2)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Box (Box(..))

result1 :: Box Int
result1 = Box (\x -> x + 1) `apply` (Box 2)

result2 :: Box Int
result2 = Box add `apply` (Box 2) `apply` (Box 3)

result3 :: Box Int
result3 = lift2 add (Box 2) (Box 4)

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Applicative Functors for multiple arguments"
  logShow $ result1
  logShow $ result2
  logShow $ result3
