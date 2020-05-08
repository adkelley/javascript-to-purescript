module Test.Main where

import Prelude

import Effect (Effect)

import Test.Data.List (testList)
import Test.Data.List.Lazy (testListLazy)
import Test.Data.List.Partial (testListPartial)
import Test.Data.List.ZipList (testZipList)
import Test.Data.List.NonEmpty (testNonEmptyList)

main :: Effect Unit
main = do
  testList
  testListLazy
  testZipList
  testListPartial
  testNonEmptyList
