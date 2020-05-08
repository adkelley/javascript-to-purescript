module Test.Data.Array.ST (testArrayST) where

import Prelude

import Control.Monad.ST as ST
import Data.Array.ST (withArray)
import Data.Array.ST as STA
import Data.Foldable (all)
import Data.Maybe (Maybe(..), isNothing)
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assert)

testArrayST :: Effect Unit
testArrayST = do

  log "run should produce an immutable array by running a constructor operation"

  assert $ STA.run (do
    arr <- STA.empty
    void $ STA.push 1 arr
    void $ STA.push 2 arr
    pure arr) == [1, 2]

  log "withArray should run an operation on a copy of an array"

  let original = [1, 2, 3]
  assert $ ST.run (withArray (STA.push 42) original) == [1, 2, 3, 42]
  assert $ original == [1, 2, 3]

  log "empty should produce an empty array"

  assert $ STA.run STA.empty == nil

  log "thaw should produce an STArray from a standard array"

  assert $ STA.run (STA.thaw [1, 2, 3]) == [1, 2, 3]

  log "freeze should produce a standard array from an STArray"

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.freeze arr) == [1, 2, 3]

  log "unsafeThaw should produce an STArray from a standard array"

  assert $ STA.run (STA.unsafeThaw [1, 2, 3]) == [1, 2, 3]

  log "pop should remove elements from an STArray"

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.pop arr
    pure arr) == [1, 2]

  log "pop should return the last element of an STArray"

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.pop arr) == Just 3

  log "pop should return Nothing when given an empty array"

  assert $ isNothing $ ST.run (do
    arr <- STA.empty
    STA.pop arr)

  log "push should append a value to the end of the array"

  assert $ STA.run (do
    arr <- STA.empty
    void $ STA.push 1 arr
    void $ STA.push 2 arr
    pure arr) == [1, 2]

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.push 4 arr
    pure arr) == [1, 2, 3, 4]

  log "push should return the new length of the array"

  assert $ ST.run (do
    arr <- STA.thaw [unit, unit, unit]
    STA.push unit arr) == 4

  log "pushAll should append multiple values to the end of the array"

  assert $ STA.run (do
    arr <- STA.empty
    void $ STA.pushAll [1, 2] arr
    pure arr) == [1, 2]

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.pushAll [4, 5, 6] arr
    pure arr) == [1, 2, 3, 4, 5, 6]

  log "pushAll should return the new length of the array"

  assert $ ST.run (do
    arr <- STA.thaw [unit, unit, unit]
    STA.pushAll [unit, unit] arr) == 5

  log "peek should return Nothing when peeking a value outside the array bounds"

  assert $ isNothing $ ST.run (do
    arr <- STA.empty
    STA.peek 0 arr)

  assert $ isNothing $ ST.run (do
    arr <- STA.thaw [1]
    STA.peek 1 arr)

  assert $ isNothing $ ST.run (do
    arr <- STA.empty
    STA.peek (-1) arr)

  log "peek should return the value at the specified index"

  assert $ ST.run (do
    arr <- STA.thaw [1]
    STA.peek 0 arr) == Just 1

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.peek 2 arr) == Just 3

  log "poke should return true when a value has been updated succesfully"

  assert $ ST.run (do
    arr <- STA.thaw [1]
    STA.poke 0 10 arr)

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.poke 2 30 arr)

  log "poke should return false when attempting to modify a value outside the array bounds"

  assert $ not $ ST.run (do
    arr <- STA.empty
    STA.poke 0 10 arr)

  assert $ not $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.poke 3 100 arr)

  assert $ not $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.poke (-1) 100 arr)

  log "poke should replace the value at the specified index"

  assert $ STA.run (do
    arr <- STA.thaw [1]
    void $ STA.poke 0 10 arr
    pure arr) == [10]

  log "poke should do nothing when attempting to modify a value outside the array bounds"

  assert $ STA.run (do
    arr <- STA.thaw [1]
    void $ STA.poke 1 2 arr
    pure arr) == [1]

  log "shift should remove elements from an STArray"

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.shift arr
    pure arr) == [2, 3]

  log "shift should return the first element of an STArray"

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3]
    STA.shift arr) == Just 1

  log "shift should return Nothing when given an empty array"

  assert $ isNothing $ ST.run (do
    arr <- STA.empty
    STA.shift arr)

  log "unshift should append a value to the front of the array"

  assert $ STA.run (do
    arr <- STA.empty
    void $ STA.unshift 1 arr
    void $ STA.unshift 2 arr
    pure arr) == [2, 1]

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.unshift 4 arr
    pure arr) == [4, 1, 2, 3]

  log "unshift should return the new length of the array"

  assert $ ST.run (do
    arr <- STA.thaw [unit, unit, unit]
    STA.unshift unit arr) == 4

  log "unshiftAll should append multiple values to the front of the array"

  assert $ STA.run (do
    arr <- STA.empty
    void $ STA.unshiftAll [1, 2] arr
    pure arr) == [1, 2]

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3]
    void $ STA.unshiftAll [4, 5, 6] arr
    pure arr) == [4, 5, 6, 1, 2, 3]

  log "unshiftAll should return the new length of the array"

  assert $ ST.run (do
    arr <- STA.thaw [unit, unit, unit]
    STA.unshiftAll [unit, unit] arr) == 5

  log "sort should reorder a list into ascending order based on the result of compare"
  assert $ STA.run (
    STA.sort =<< STA.unsafeThaw [1, 3, 2, 5, 6, 4]
  ) == [1, 2, 3, 4, 5, 6]

  log "sortBy should reorder a list into ascending order based on the result of a comparison function"
  assert $ STA.run (
    STA.sortBy (flip compare) =<< STA.unsafeThaw [1, 3, 2, 5, 6, 4]
  ) == [6, 5, 4, 3, 2, 1]

  log "sortWith should reorder a list into ascending order based on the result of compare over a projection"
  assert $ STA.run (
    STA.sortWith identity =<< STA.unsafeThaw [1, 3, 2, 5, 6, 4]
  ) == [1, 2, 3, 4, 5, 6]

  log "splice should be able to delete multiple items at a specified index"

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3, 4, 5]
    void $ STA.splice 1 3 [] arr
    pure arr) == [1, 5]

  log "splice should return the items removed"

  assert $ ST.run (do
    arr <- STA.thaw [1, 2, 3, 4, 5]
    STA.splice 1 3 [] arr) == [2, 3, 4]

  log "splice should be able to insert multiple items at a specified index"

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3, 4, 5]
    void $ STA.splice 1 0 [0, 100] arr
    pure arr) == [1, 0, 100, 2, 3, 4, 5]

  log "splice should be able to delete and insert at the same time"

  assert $ STA.run (do
    arr <- STA.thaw [1, 2, 3, 4, 5]
    void $ STA.splice 1 2 [0, 100] arr
    pure arr) == [1, 0, 100, 4, 5]

  log "toAssocArray should return all items in the array with the correct indices and values"

  assert $ all (\{ value: v, index: i } -> v == i + 1) $ ST.run (do
    arr <- STA.thaw [1, 2, 3, 4, 5]
    STA.toAssocArray arr)

  assert $ all (\{ value: v, index: i } -> v == (i + 1) * 10) $ ST.run (do
    arr <- STA.thaw [10, 20, 30, 40, 50]
    STA.toAssocArray arr)

nil :: Array Int
nil = []
