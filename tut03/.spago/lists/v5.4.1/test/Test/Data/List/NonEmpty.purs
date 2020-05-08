module Test.Data.List.NonEmpty (testNonEmptyList) where

import Prelude

import Data.Foldable (class Foldable, foldM, foldMap, foldl, length)
import Data.FoldableWithIndex (foldlWithIndex, foldrWithIndex, foldMapWithIndex)
import Data.List as L
import Data.List.NonEmpty as NEL
import Data.Maybe (Maybe(..))
import Data.Monoid.Additive (Additive(..))
import Data.NonEmpty ((:|))
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (replicate1, unfoldr1)
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assert)

testNonEmptyList :: Effect Unit
testNonEmptyList = do
  let
    nel :: ∀ f a. Foldable f => a -> f a -> NEL.NonEmptyList a
    nel x xs = NEL.NonEmptyList $ x :| L.fromFoldable xs
    l :: ∀ f a. Foldable f => f a -> L.List a
    l = L.fromFoldable

  log "singleton should construct a non-empty list with a single value"
  assert $ NEL.singleton 1 == nel 1 []
  assert $ NEL.singleton "foo" == nel "foo" []

  log "length should return the number of items in a non-empty list"
  assert $ length (nel 1 []) == 1
  assert $ length (nel 1 [2, 3, 4, 5]) == 5

  log "length should be stack-safe"
  void $ pure $ NEL.length $ nel 0 (L.range 1 100000)

  log "snoc should add an item to the end of a non-empty list"
  assert $ nel 1 [2, 3] `NEL.snoc` 4 == nel 1 [2, 3, 4]

  log "head should return a first value of a non-empty list"
  assert $ NEL.head (nel "foo" ["bar"]) == "foo"

  log "last should return a last value of a non-empty list"
  assert $ NEL.last (nel "foo" ["bar"]) == "bar"

  log "tail should return a list containing all the items in a non-empty list apart from the first"
  assert $ NEL.tail (nel "foo" ["bar", "baz"]) == (l ["bar", "baz"])

  log "init should return a list containing all the items in a non-empty list apart from the last"
  assert $ NEL.init (nel "foo" ["bar", "baz"]) == (l ["foo", "bar"])

  log "uncons should split a non-empty list into a head and tail record when there is at least one item"
  let u1 = NEL.uncons (nel 1 [])
  assert $ u1.head == 1
  assert $ u1.tail == l []
  let u2 = NEL.uncons (nel 1 [2, 3])
  assert $ u2.head == 1
  assert $ u2.tail == l [2, 3]

  log "unsnoc should split a non-empty list into an init and last record when there is at least one item"
  let v1 = NEL.unsnoc (nel 1 [])
  assert $ v1.init == l []
  assert $ v1.last == 1
  let v2 = NEL.unsnoc (nel 1 [2, 3])
  assert $ v2.init == l [1, 2]
  assert $ v2.last == 3

  log "(!!) should return Just x when the index is within the bounds of the non-empty list"
  assert $ nel 1 [2, 3] NEL.!! 0 == (Just 1)
  assert $ nel 1 [2, 3] NEL.!! 1 == (Just 2)
  assert $ nel 1 [2, 3] NEL.!! 2 == (Just 3)

  log "(!!) should return Nothing when the index is outside of the bounds of the non-empty list"
  assert $ nel 1 [2, 3] NEL.!! 6 == Nothing
  assert $ nel 1 [2, 3] NEL.!! (-1) == Nothing

  log "elemIndex should return the index of an item that a predicate returns true for in a non-empty list"
  assert $ NEL.elemIndex 1 (nel 1 [2, 1]) == Just 0
  assert $ NEL.elemIndex 4 (nel 1 [2, 1]) == Nothing

  log "elemLastIndex should return the last index of an item in a non-empty list"
  assert $ NEL.elemLastIndex 1 (nel 1 [2, 1]) == Just 2
  assert $ NEL.elemLastIndex 4 (nel 1 [2, 1]) == Nothing

  log "findIndex should return the index of an item that a predicate returns true for in a non-empty list"
  assert $ NEL.findIndex (_ /= 1) (nel 1 [2, 1]) == Just 1
  assert $ NEL.findIndex (_ == 3) (nel 1 [2, 1]) == Nothing

  log "findLastIndex should return the last index of an item in a non-empty list"
  assert $ NEL.findLastIndex (_ /= 1) (nel 2 [1, 2]) == Just 2
  assert $ NEL.findLastIndex (_ == 3) (nel 2 [1, 2]) == Nothing

  log "insertAt should add an item at the specified index"
  assert $ (NEL.insertAt 0 1 (nel 2 [3])) == Just (nel 1 [2, 3])
  assert $ (NEL.insertAt 1 1 (nel 2 [3])) == Just (nel 2 [1, 3])
  assert $ (NEL.insertAt 2 1 (nel 2 [3])) == Just (nel 2 [3, 1])

  log "insertAt should return Nothing if the index is out of range"
  assert $ (NEL.insertAt 2 1 (nel 0 [])) == Nothing

  log "updateAt should replace an item at the specified index"
  assert $ (NEL.updateAt 0 9 (nel 1 [2, 3])) == Just (nel 9 [2, 3])
  assert $ (NEL.updateAt 1 9 (nel 1 [2, 3])) == Just (nel 1 [9, 3])

  log "updateAt should return Nothing if the index is out of range"
  assert $ (NEL.updateAt 1 9 (nel 0 [])) == Nothing

  log "modifyAt should update an item at the specified index"
  assert $ (NEL.modifyAt 0 (_ + 1) (nel 1 [2, 3])) == Just (nel 2 [2, 3])
  assert $ (NEL.modifyAt 1 (_ + 1) (nel 1 [2, 3])) == Just (nel 1 [3, 3])

  log "modifyAt should return Nothing if the index is out of range"
  assert $ (NEL.modifyAt 1 (_ + 1) (nel 0 [])) == Nothing

  log "reverse should reverse the order of items in an list"
  assert $ (NEL.reverse (nel 1 [2, 3])) == nel 3 [2, 1]

  log "concat should join an list of lists"
  assert $ (NEL.concat (nel (nel 1 [2]) [nel 3 [4]])) == nel 1 [2, 3, 4]

  log "concatMap should be equivalent to (concat <<< map)"
  assert $ NEL.concatMap doubleAndOrig (nel 1 [2, 3]) == NEL.concat (map doubleAndOrig (nel 1 [2, 3]))

  log "filter should remove items that don't match a predicate"
  assert $ NEL.filter odd (nel 0 (L.range 1 10)) == l [1, 3, 5, 7, 9]

  log "filterM should remove items that don't match a predicate while using a monadic behaviour"
  assert $ NEL.filterM (Just <<< odd) (nel 0 (L.range 1 10)) == Just (l [1, 3, 5, 7, 9])
  assert $ NEL.filterM (const Nothing) (nel 0 (L.range 1 10)) == Nothing

  log "mapMaybe should transform every item in an list, throwing out Nothing values"
  assert $ NEL.mapMaybe (\x -> if x /= 0 then Just x else Nothing) (nel 0 [1, 0, 0, 2, 3]) == l [1, 2, 3]

  log "catMaybe should take an list of Maybe values and throw out Nothings"
  assert $ NEL.catMaybes (nel Nothing [Just 2, Nothing, Just 4]) == l [2, 4]

  log "mapWithIndex should take a list of values and apply a function which also takes the index into account"
  assert $ NEL.mapWithIndex (\x ix -> x + ix) (nel 0 [1, 2, 4]) == nel 0 [2, 4, 7]

  log "sort should reorder a non-empty list into ascending order based on the result of compare"
  assert $ NEL.sort (nel 1 [3, 2, 5, 6, 4]) == nel 1 [2, 3, 4, 5, 6]

  log "sortBy should reorder a non-empty list into ascending order based on the result of a comparison function"
  assert $ NEL.sortBy (flip compare) (nel 1 [3, 2, 5, 6, 4]) == nel 6 [5, 4, 3, 2, 1]

  log "take should keep the specified number of items from the front of an list, discarding the rest"
  assert $ (NEL.take 1 (nel 1 [2, 3])) == l [1]
  assert $ (NEL.take 2 (nel 1 [2, 3])) == l [1, 2]

  log "takeWhile should keep all values that match a predicate from the front of an list"
  assert $ (NEL.takeWhile (_ /= 2) (nel 1 [2, 3])) == l [1]
  assert $ (NEL.takeWhile (_ /= 3) (nel 1 [2, 3])) == l [1, 2]

  log "drop should remove the specified number of items from the front of an list"
  assert $ (NEL.drop 1 (nel 1 [2, 3])) == l [2, 3]
  assert $ (NEL.drop 2 (nel 1 [2, 3])) == l [3]

  log "dropWhile should remove all values that match a predicate from the front of an list"
  assert $ (NEL.dropWhile (_ /= 1) (nel 1 [2, 3])) == l [1, 2, 3]
  assert $ (NEL.dropWhile (_ /= 2) (nel 1 [2, 3])) == l [2, 3]

  log "span should split an list in two based on a predicate"
  let spanResult = NEL.span (_ < 4) (nel 1 [2, 3, 4, 5, 6, 7])
  assert $ spanResult.init == l [1, 2, 3]
  assert $ spanResult.rest == l [4, 5, 6, 7]

  log "group should group consecutive equal elements into lists"
  assert $ NEL.group (nel 1 [2, 2, 3, 3, 3, 1]) == nel (nel 1 []) [nel 2 [2], nel 3 [3, 3], nel 1 []]

  log "group' should sort then group consecutive equal elements into lists"
  assert $ NEL.group' (nel 1 [2, 2, 3, 3, 3, 1]) == nel (nel 1 [1]) [nel 2 [2], nel 3 [3, 3]]

  log "groupBy should group consecutive equal elements into lists based on an equivalence relation"
  assert $ NEL.groupBy (\x y -> odd x && odd y) (nel 1 [1, 2, 2, 3, 3]) == nel (nel 1 [1]) [nel 2 [], nel 2 [], nel 3 [3]]

  log "partition should separate a list into a tuple of lists that do and do not satisfy a predicate"
  let partitioned = NEL.partition (_ > 2) (nel 1 [5, 3, 2, 4])
  assert $ partitioned.yes == l [5, 3, 4]
  assert $ partitioned.no == l [1, 2]

  log "nub should remove duplicate elements from the list, keeping the first occurence"
  assert $ NEL.nub (nel 1 [2, 2, 3, 4, 1]) == nel 1 [2, 3, 4]

  log "nubBy should remove duplicate items from the list using a supplied predicate"
  let nubPred = \x y -> if odd x then false else x == y
  assert $ NEL.nubBy nubPred (nel 1 [2, 2, 3, 3, 4, 4, 1]) == nel 1 [2, 3, 3, 4, 1]

  log "union should produce the union of two lists"
  assert $ NEL.union (nel 1 [2, 3]) (nel 2 [3, 4]) == nel 1 [2, 3, 4]
  assert $ NEL.union (nel 1 [1, 2, 3]) (nel 2 [3, 4]) == nel 1 [1, 2, 3, 4]

  log "unionBy should produce the union of two lists using the specified equality relation"
  assert $ NEL.unionBy (\_ y -> y < 5) (nel 1 [2, 3]) (nel 2 [3, 4, 5, 6]) == nel 1 [2, 3, 5, 6]

  log "intersect should return the intersection of two lists"
  assert $ NEL.intersect (nel 1 [2, 3, 4, 3, 2, 1]) (nel 1 [1, 2, 3]) == nel 1 [2, 3, 3, 2, 1]

  log "intersectBy should return the intersection of two lists using the specified equivalence relation"
  assert $ NEL.intersectBy (\x y -> (x * 2) == y) (nel 1 [2, 3]) (nel 2 [6]) == nel 1 [3]

  log "zipWith should use the specified function to zip two lists together"
  assert $ NEL.zipWith (\x y -> nel (show x) [y]) (nel 1 [2, 3]) (nel "a" ["b", "c"]) == nel (nel "1" ["a"]) [nel "2" ["b"], nel "3" ["c"]]

  log "zipWithA should use the specified function to zip two lists together"
  assert $ NEL.zipWithA (\x y -> Just $ Tuple x y) (nel 1 [2, 3]) (nel "a" ["b", "c"]) == Just (nel (Tuple 1 "a") [Tuple 2 "b", Tuple 3 "c"])

  log "zip should use the specified function to zip two lists together"
  assert $ NEL.zip (nel 1 [2, 3]) (nel "a" ["b", "c"]) == nel (Tuple 1 "a") [Tuple 2 "b", Tuple 3 "c"]

  log "unzip should deconstruct a list of tuples into a tuple of lists"
  log $ show $ NEL.unzip (nel (Tuple 1 "a") [Tuple 2 "b", Tuple 3 "c"])
  assert $ NEL.unzip (nel (Tuple 1 "a") [Tuple 2 "b", Tuple 3 "c"]) == Tuple (nel 1 [2, 3]) (nel "a" ["b", "c"])

  log "foldM should perform a fold using a monadic step function"
  assert $ foldM (\x y -> Just (x + y)) 0 (nel 1 (L.range 2 10)) == Just 55

  log "foldl should be stack-safe"
  void $ pure $ foldl (+) 0 $ nel 0 (L.range 1 100000)

  log "foldMap should be stack-safe"
  void $ pure $ foldMap Additive $ nel 0 (L.range 1 100000)

  log "foldMap should be left-to-right"
  assert $ foldMap show (nel 1 (L.range 2 5)) == "12345"

  log "map should maintain order"
  assert $ nel 0 (L.range 1 5) == map identity (nel 0 (L.range 1 5))

  log "traverse1 should be stack-safe"
  let xs = nel 0 (L.range 1 100000)
  assert $ NEL.traverse1 Just xs == Just xs

  log "traverse1 should preserve order"
  let ts = nel 0 [1, 2, 3, 4, 5]
  assert $ NEL.traverse1 Just ts == Just ts

  log "append should concatenate two lists"
  assert $ (nel 1 [2]) <> (nel 3 [4]) == (nel 1 [2, 3, 4])

  log "append should be stack-safe"
  void $ pure $ xs <> xs

  log "foldlWithIndex should be correct"
  assert $ (foldlWithIndex (\i b _ -> i + b) 0 <$> (NEL.fromFoldable (L.range 0 10000))) == Just 50005000

  log "foldlWithIndex should be stack-safe"
  void $ pure $ map (foldlWithIndex (\i b _ -> i + b) 0) $ NEL.fromFoldable $ L.range 0 100000

  log "foldrWithIndex should be correct"
  assert $ (foldrWithIndex (\i _ b -> i + b) 0 <$> (NEL.fromFoldable (L.range 0 10000))) == Just 50005000

  log "foldrWithIndex should be stack-safe"
  void $ pure $ map (foldrWithIndex (\i b _ -> i + b) 0) $ NEL.fromFoldable $ L.range 0 100000

  log "foldMapWithIndex should be stack-safe"
  void $ pure $ map (foldMapWithIndex (\i _ -> Additive i)) $ NEL.fromFoldable $ L.range 1 100000

  log "foldMapWithIndex should be left-to-right"
  assert $ map (foldMapWithIndex (\i _ -> show i)) (NEL.fromFoldable [0, 0, 0]) == Just "012"

  log "traverseWithIndex should be stack-safe"
  assert $ map (traverseWithIndex (const Just)) (NEL.fromFoldable xs) == Just (NEL.fromFoldable xs)

  log "traverseWithIndex should be correct"
  assert $ map (traverseWithIndex (\i a -> Just $ i + a)) (NEL.fromFoldable [2, 2, 2])
           == Just (NEL.fromFoldable [2, 3, 4])

  log "unfoldable replicate1 should be stack-safe"
  void $ pure $ NEL.length $ (replicate1 100000 1 :: NEL.NonEmptyList Int)

  log "unfoldr1 should maintain order"
  assert $ (nel 1 [2, 3, 4, 5]) == unfoldr1 step1 1

step :: Int -> Maybe (Tuple Int Int)
step 6 = Nothing
step n = Just (Tuple n (n + 1))

step1 :: Int -> Tuple Int (Maybe Int)
step1 n = Tuple n (if n >= 5 then Nothing else Just (n + 1))

odd :: Int -> Boolean
odd n = n `mod` 2 /= zero

doubleAndOrig :: Int -> NEL.NonEmptyList Int
doubleAndOrig x = NEL.NonEmptyList (x * 2 :| x L.: L.Nil)
