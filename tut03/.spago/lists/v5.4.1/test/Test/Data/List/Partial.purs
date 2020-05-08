module Test.Data.List.Partial (testListPartial) where

import Prelude

import Effect (Effect)
import Effect.Console (log)

import Data.List (List(..), fromFoldable)
import Data.List.Partial (init, tail, last, head)

import Partial.Unsafe (unsafePartial)

import Test.Assert (assert, assertThrows)

testListPartial :: Effect Unit
testListPartial = do
  let l = fromFoldable

  log "head should return a Just-wrapped first value of a non-empty list"
  assert $ unsafePartial $ head (l ["foo", "bar"]) == "foo"

  log "head should throw an error for an empty list"
  assertThrows \_ -> unsafePartial $ head Nil

  log "last should return a Just-wrapped last value of a non-empty list"
  assert $ unsafePartial $ last (l ["foo", "bar"]) == "bar"

  log "last should throw an error for an empty list"
  assertThrows \_ -> unsafePartial $ last Nil

  log "tail should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ unsafePartial $ tail (l ["foo", "bar", "baz"]) == l ["bar", "baz"]

  log "tail should throw an error for an empty list"
  assertThrows \_ -> unsafePartial $ tail Nil

  log "init should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ unsafePartial $ init (l ["foo", "bar", "baz"]) == l ["foo", "bar"]

  log "init should throw an error for an empty list"
  assertThrows \_ -> unsafePartial $ init Nil
