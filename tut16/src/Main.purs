module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log, logShow)
import Data.Box (Box(..))

-- Monad law 1 join(m.map(join)) == join(join(m))
m1 :: Box (Box (Box Int))
m1 = Box $ Box $ Box 3

result1 :: Box Int
result1 = join $ map join m1

result2 :: Box Int
result2 = join $ join m1

-- Monad law 2: join(Box.of(m) == join(m.map(Box.of)))
m2 :: Box String
m2 = Box "Wonder"

result3 :: Box String
result3 = join $ pure m2

result4 :: Box String
result4 = join $ map pure m2

main :: Effect Unit
main = do
  log "You've been using Monads"
  logShow $ result1
  logShow $ result2
  logShow $ result1 == result2
  logShow $ result3
  logShow $ result4
  logShow $ result3 == result4
