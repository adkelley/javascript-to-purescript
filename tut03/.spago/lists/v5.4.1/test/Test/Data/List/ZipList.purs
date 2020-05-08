module Test.Data.List.ZipList (testZipList) where

import Prelude

import Effect (Effect)
import Effect.Console (log)

import Data.Array as Array
import Data.List.Lazy as LazyList
import Data.List.ZipList (ZipList(..))

import Test.Assert (assert)

testZipList :: Effect Unit
testZipList = do
  log "ZipList Applicative instance should be zippy"
  testZipWith (+)   [1,2,3] [4,5,6]
  testZipWith (*)   [1,2,3] [4,5,6]
  testZipWith const [1,2,3] [4,5,6]

testZipWith :: forall a b c. Eq c => (a -> b -> c) -> Array a -> Array b -> Effect Unit
testZipWith f xs ys =
  assert $ (f <$> l xs <*> l ys) == l (Array.zipWith f xs ys)

-- Shortcut for constructing a ZipList
l :: forall a. Array a -> ZipList a
l = ZipList <<< LazyList.fromFoldable
