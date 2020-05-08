module Test.Data.String.CaseInsensitive (testCaseInsensitiveString) where

import Prelude

import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assertEqual)

testCaseInsensitiveString :: Effect Unit
testCaseInsensitiveString = do
  log "equality"
  assertEqual
    { actual: CaseInsensitiveString "aB"
    , expected: CaseInsensitiveString "AB"
    }

  log "comparison"
  assertEqual
    { actual: compare (CaseInsensitiveString "qwerty") (CaseInsensitiveString "QWERTY")
    , expected: EQ
    }
