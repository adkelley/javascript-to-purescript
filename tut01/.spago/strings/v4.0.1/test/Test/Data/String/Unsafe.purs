module Test.Data.String.Unsafe (testStringUnsafe) where

import Prelude

import Data.String.Unsafe as SU
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assertEqual)

testStringUnsafe :: Effect Unit
testStringUnsafe = do
  log "charAt"
  assertEqual
    { actual: SU.charAt 0 "ab"
    , expected: 'a'
    }
  assertEqual
    { actual: SU.charAt 1 "ab"
    , expected: 'b'
    }

  log "char"
  assertEqual
    { actual: SU.char "a"
    , expected: 'a'
    }
