module Test.Data.String.Regex (testStringRegex) where

import Data.String.Regex

import Data.Array.NonEmpty (NonEmptyArray, fromArray)
import Data.Either (isLeft)
import Data.Maybe (Maybe(..), fromJust)
import Data.String.Regex.Flags (global, ignoreCase, noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Prelude (type (~>), Unit, discard, not, ($), (<<<), (<>), (==))
import Test.Assert (assert)

testStringRegex :: Effect Unit
testStringRegex = do
  log "regex"
  assert $ test (unsafeRegex "^a" noFlags) "abc"
  assert $ not (test (unsafeRegex "^b" noFlags) "abc")
  assert $ isLeft (regex "+" noFlags)

  log "flags"
  assert $ "quxbarfoobaz" == replace (unsafeRegex "foo" noFlags) "qux" "foobarfoobaz"
  assert $ "quxbarquxbaz" == replace (unsafeRegex "foo" global) "qux" "foobarfoobaz"
  assert $ "quxbarquxbaz" == replace (unsafeRegex "foo" (global <> ignoreCase)) "qux" "foobarFOObaz"

  log "match"
  assert $ match (unsafeRegex "^abc$" noFlags) "abc" == Just (nea [Just "abc"])
  assert $ match (unsafeRegex "^abc$" noFlags) "xyz" == Nothing

  log "replace"
  assert $ replace (unsafeRegex "-" noFlags) "!" "a-b-c" == "a!b-c"

  log "replace'"
  assert $ replace' (unsafeRegex "-" noFlags) (\s xs -> "!") "a-b-c" == "a!b-c"

  log "search"
  assert $ search (unsafeRegex "b" noFlags) "abc" == Just 1
  assert $ search (unsafeRegex "d" noFlags) "abc" == Nothing

  log "split"
  assert $ split (unsafeRegex "" noFlags) "" == []
  assert $ split (unsafeRegex "" noFlags) "abc" == ["a", "b", "c"]
  assert $ split (unsafeRegex "b" noFlags) "" == [""]
  assert $ split (unsafeRegex "b" noFlags) "abc" == ["a", "c"]

  log "test"
  -- Ensure that we have referential transparency for calls to 'test'. No
  -- global state should be maintained between these two calls:
  let pattern = unsafeRegex "a" (parseFlags "g")
  assert $ test pattern "a"
  assert $ test pattern "a"

nea :: Array ~> NonEmptyArray
nea = unsafePartial fromJust <<< fromArray
