
module Test.Main where

import Prelude

import Data.Newtype (un)
import Data.Ord.Down (Down(..))
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assertEqual)

main :: Effect Unit
main = do
  log "Down provides an inverted Ord instance"
  assertEqual
    { actual: compare (Down 1) (Down 1)
    , expected: compare 1 1
    }
  assertEqual
    { actual: compare (Down 1) (Down 2)
    , expected: compare 2 1
    }
  assertEqual
    { actual: compare (Down 2) (Down 1)
    , expected: compare 1 2
    }

  log "top/bottom"
  assertEqual
    { actual: un Down (top :: Down Int)
    , expected: bottom :: Int
    }
  assertEqual
    { actual: un Down (bottom :: Down Int)
    , expected: top :: Int
    }
