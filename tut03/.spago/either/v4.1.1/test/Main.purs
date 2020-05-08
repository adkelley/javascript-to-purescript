module Test.Main where

import Prelude

import Data.Either.Inject (inj, prj)
import Data.Either.Nested (Either3, in1, in2, in3)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assertEqual)

type MySum = Either3 Boolean String Int

main :: Effect Unit
main = do
  log "Test injection"
  assertEqual
    { actual: inj true :: MySum
    , expected: in1 true
    }
  assertEqual
    { actual: inj "hello" :: MySum
    , expected: in2 "hello"
    }
  assertEqual
    { actual: inj 100 :: MySum
    , expected: in3 100
    }
  log "Test injection with the injectReflexive instance"
  assertEqual
    let
      x = inj 100 :: MySum
    in
      { actual: inj x :: MySum
      , expected: x
      }
  log "Test that injection picks the left-most option"
  assertEqual
    { actual: inj 100 :: Either3 Int Int Int
    , expected: in1 100
    }
  log "Test projection"
  assertEqual
    { actual: prj (in1 true :: MySum)
    , expected: Just true
    }
  assertEqual
    { actual: prj (in2 "hello" :: MySum)
    , expected: Just "hello"
    }
  assertEqual
    { actual: prj (in3 100 :: MySum)
    , expected: Just 100
    }
  assertEqual
    { actual: prj (in1 true :: MySum)
    , expected: Nothing :: Maybe String
    }
  assertEqual
    { actual: prj (in2 "hello" :: MySum)
    , expected: Nothing :: Maybe Int
    }
  assertEqual
    { actual: prj (in3 100 :: MySum)
    , expected: Nothing :: Maybe Boolean
    }
