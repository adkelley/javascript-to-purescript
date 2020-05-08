module Test.Data.Array.ST.Partial (testArraySTPartial) where

import Prelude

import Control.Monad.ST as ST
import Data.Array.ST (thaw, unsafeFreeze)
import Data.Array.ST.Partial as STAP
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assert)

testArraySTPartial :: Effect Unit
testArraySTPartial = do

  log "peekSTArray should return the value at the specified index"
  assert $ 2 == ST.run do
    a <- thaw [1, 2, 3]
    unsafePartial $ STAP.peek 1 a

  log "pokeSTArray should modify the value at the specified index"
  assert $ [1, 4, 3] == ST.run do
    a <- thaw [1, 2, 3]
    unsafePartial $ STAP.poke 1 4 a
    unsafeFreeze a
