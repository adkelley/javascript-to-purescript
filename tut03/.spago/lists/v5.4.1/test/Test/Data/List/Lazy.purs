module Test.Data.List.Lazy (testListLazy) where

import Prelude

import Control.Lazy (defer)
import Data.FoldableWithIndex (foldMapWithIndex, foldlWithIndex, foldrWithIndex)
import Data.FunctorWithIndex (mapWithIndex)
import Data.Lazy as Z
import Data.List.Lazy (List, Pattern(..), alterAt, catMaybes, concat, concatMap, cons, delete, deleteAt, deleteBy, drop, dropWhile, elemIndex, elemLastIndex, filter, filterM, findIndex, findLastIndex, foldM, foldMap, foldl, foldr, foldrLazy, fromFoldable, group, groupBy, head, init, insert, insertAt, insertBy, intersect, intersectBy, iterate, last, length, mapMaybe, modifyAt, nil, nub, nubBy, null, partition, range, repeat, replicate, replicateM, reverse, scanrLazy, singleton, slice, snoc, span, stripPrefix, tail, take, takeWhile, transpose, uncons, union, unionBy, unzip, updateAt, zip, zipWith, zipWithA, (!!), (..), (:), (\\))
import Data.List.Lazy.NonEmpty as NEL
import Data.Maybe (Maybe(..), isNothing, fromJust)
import Data.Monoid.Additive (Additive(..))
import Data.NonEmpty ((:|))
import Data.Traversable (traverse)
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (replicate1, unfoldr)
import Data.Unfoldable1 (unfoldr1)
import Effect (Effect)
import Effect.Console (log)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assert)

testListLazy :: Effect Unit
testListLazy = do
  let
    l = fromFoldable
    nel xxs = NEL.NonEmptyList (Z.defer \_ -> xxs)
    longList = range 1 100000
  log "strip prefix"
  assert $ stripPrefix (Pattern (l [1])) (l [1,2]) == Just (l [2])
  assert $ stripPrefix (Pattern (l [])) (l [1]) == Just (l [1])
  assert $ stripPrefix (Pattern (l [2])) (l [1]) == Nothing

  log "append should be stack-safe"
  assert $ length (longList <> longList) == (2 * length longList)

  log "map should be stack-safe"
  assert $ (last $ (_ + 1) <$> longList) == ((_ + 1) <$> last longList)

  log "foldl should be stack-safe"
  void $ pure $ foldl (+) 0 longList

  log "foldr should be stack-safe"
  void $ pure $ foldr (+) 0 longList

  log "foldMap should be stack-safe"
  void $ pure $ foldMap Additive longList

  log "foldMap should be left-to-right"
  assert $ foldMap show (range 1 5) == "12345"

  log "foldlWithIndex should be correct"
  assert $ foldlWithIndex (\i b _ -> i + b) 0 (range 0 10000) == 50005000
  assert $ map (foldlWithIndex (\i b _ -> i + b) 0) (NEL.fromFoldable (range 0 10000)) == Just 50005000

  log "foldlWithIndex should be stack-safe"
  void $ pure $ foldlWithIndex (\i b _ -> i + b) 0 $ range 0 100000
  void $ pure $ map (foldlWithIndex (\i b _ -> i + b) 0) $ NEL.fromFoldable $ range 0 100000

  log "foldrWithIndex should be correct"
  assert $ foldrWithIndex (\i _ b -> i + b) 0 (range 0 10000) == 50005000
  assert $ map (foldrWithIndex (\i _ b -> i + b) 0) (NEL.fromFoldable (range 0 10000)) == Just 50005000

  log "foldrWithIndex should be stack-safe"
  void $ pure $ foldrWithIndex (\i _ b -> i + b) 0 $ range 0 100000
  void $ pure $ map (foldrWithIndex (\i _ b -> i + b) 0) $ NEL.fromFoldable $ range 0 100000

  log "foldMapWithIndex should be stack-safe"
  void $ pure $ foldMapWithIndex (\i _ -> Additive i) $ range 1 100000
  void $ pure $ map (foldMapWithIndex (\i _ -> Additive i)) $ NEL.fromFoldable $ range 1 100000

  log "foldMapWithIndex should be left-to-right"
  assert $ foldMapWithIndex (\i _ -> show i) (fromFoldable [0, 0, 0]) == "012"
  assert $ map (foldMapWithIndex (\i _ -> show i)) (NEL.fromFoldable [0, 0, 0]) == Just "012"

  log "traverse should be stack-safe"
  assert $ ((traverse Just longList) >>= last) == last longList

  log "traverseWithIndex should be stack-safe"
  assert $ traverseWithIndex (const Just) longList == Just longList
  assert $ traverseWithIndex (const Just) (NEL.fromFoldable longList) == Just (NEL.fromFoldable longList)

  log "traverseWithIndex should be correct"
  assert $ traverseWithIndex (\i a -> Just $ i + a) (fromFoldable [2, 2, 2])
           == Just (fromFoldable [2, 3, 4])
  assert $ map (traverseWithIndex (\i a -> Just $ i + a)) (NEL.fromFoldable [2, 2, 2])
           == Just (NEL.fromFoldable [2, 3, 4])

  log "bind should be stack-safe"
  void $ pure $ last $ longList >>= pure

  log "singleton should construct an list with a single value"
  assert $ singleton 1 == l [1]
  assert $ singleton "foo" == l ["foo"]
  assert $ singleton nil' == l [l []]

  log "range should create an inclusive list of integers for the specified start and end"
  assert $ (range 0 5) == l [0, 1, 2, 3, 4, 5]
  assert $ (range 2 (-3)) == l [2, 1, 0, -1, -2, -3]

  log "range should be lazy"
  assert $ head (range 0 100000000) == Just 0

  log "replicate should produce an list containg an item a specified number of times"
  assert $ replicate 3 true == l [true, true, true]
  assert $ replicate 1 "foo" == l ["foo"]
  assert $ replicate 0 "foo" == l []
  assert $ replicate (-1) "foo" == l []

  log "replicateM should perform the monadic action the correct number of times"
  assert $ replicateM 3 (Just 1) == Just (l [1, 1, 1])
  assert $ replicateM 1 (Just 1) == Just (l [1])
  assert $ replicateM 0 (Just 1) == Just (l [])
  assert $ replicateM (-1) (Just 1) == Just (l [])

  -- some
  -- many

  log "null should return false for non-empty lists"
  assert $ null (l [1]) == false
  assert $ null (l [1, 2, 3]) == false

  log "null should return true for an empty list"
  assert $ null nil' == true

  log "length should be stack-safe"
  assert $ length longList == 100000

  log "length should return the number of items in an list"
  assert $ length nil' == 0
  assert $ length (l [1]) == 1
  assert $ length (l [1, 2, 3, 4, 5]) == 5

  log "snoc should add an item to the end of an list"
  assert $ l [1, 2, 3] `snoc` 4 == l [1, 2, 3, 4]
  assert $ nil' `snoc` 1 == l [1]

  log "insert should be stack-safe"
  assert $ last (insert 100001 longList) == Just 100001

  log "insert should add an item at the appropriate place in a sorted list"
  assert $ insert 1.5 (l [1.0, 2.0, 3.0]) == l [1.0, 1.5, 2.0, 3.0]
  assert $ insert 4 (l [1, 2, 3]) == l [1, 2, 3, 4]
  assert $ insert 0 (l [1, 2, 3]) == l [0, 1, 2, 3]

  log "insertBy should add an item at the appropriate place in a sorted list using the specified comparison"
  assert $ insertBy (flip compare) 4 (l [1, 2, 3]) == l [4, 1, 2, 3]
  assert $ insertBy (flip compare) 0 (l [1, 2, 3]) == l [1, 2, 3, 0]

  log "head should return a Just-wrapped first value of a non-empty list"
  assert $ head (l ["foo", "bar"]) == Just "foo"

  log "head should return Nothing for an empty list"
  assert $ head nil' == Nothing

  log "last should return a Just-wrapped last value of a non-empty list"
  assert $ last (l ["foo", "bar"]) == Just "bar"

  log "last should return Nothing for an empty list"
  assert $ last nil' == Nothing

  log "tail should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ tail (l ["foo", "bar", "baz"]) == Just (l ["bar", "baz"])

  log "tail should return Nothing for an empty list"
  assert $ tail nil' == Nothing

  log "init should return a Just-wrapped list containing all the items in an list apart from the first for a non-empty list"
  assert $ init (l ["foo", "bar", "baz"]) == Just (l ["foo", "bar"])

  log "init should return Nothing for an empty list"
  assert $ init nil' == Nothing

  log "uncons should return nothing when used on an empty list"
  assert $ isNothing (uncons nil')

  log "uncons should split an list into a head and tail record when there is at least one item"
  let u1 = uncons (l [1])
  assert $ unsafePartial (fromJust u1).head == 1
  assert $ unsafePartial(fromJust u1).tail == l []
  let u2 = uncons (l [1, 2, 3])
  assert $ unsafePartial (fromJust u2).head == 1
  assert $ unsafePartial (fromJust u2).tail == l [2, 3]

  log "(!!) should return Just x when the index is within the bounds of the list"
  assert $ l [1, 2, 3] !! 0 == (Just 1)
  assert $ l [1, 2, 3] !! 1 == (Just 2)
  assert $ l [1, 2, 3] !! 2 == (Just 3)

  log "(!!) should return Nothing when the index is outside of the bounds of the list"
  assert $ l [1, 2, 3] !! 6 == Nothing
  assert $ l [1, 2, 3] !! (-1) == Nothing

  log "elemIndex should return the index of an item that a predicate returns true for in an list"
  assert $ elemIndex 1 (l [1, 2, 1]) == Just 0
  assert $ elemIndex 4 (l [1, 2, 1]) == Nothing

  log "elemLastIndex should return the last index of an item in an list"
  assert $ elemLastIndex 1 (l [1, 2, 1]) == Just 2
  assert $ elemLastIndex 4 (l [1, 2, 1]) == Nothing

  log "findIndex should return the index of an item that a predicate returns true for in an list"
  assert $ findIndex (_ /= 1) (l [1, 2, 1]) == Just 1
  assert $ findIndex (_ == 3) (l [1, 2, 1]) == Nothing

  log "findIndex should work on huge lists"
  assert $ findIndex (_ == 3) (range 0 100000000) == Just 3

  log "findLastIndex should return the last index of an item in an list"
  assert $ findLastIndex (_ /= 1) (l [2, 1, 2]) == Just 2
  assert $ findLastIndex (_ == 3) (l [2, 1, 2]) == Nothing

  log "insertAt should add an item at the specified index"
  assert $ (insertAt 0 1 (l [2, 3])) == (l [1, 2, 3])
  assert $ (insertAt 1 1 (l [2, 3])) == (l [2, 1, 3])
  assert $ (insertAt 2 1 (l [2, 3])) == (l [2, 3, 1])

  log "deleteAt should remove an item at the specified index"
  assert $ (deleteAt 0 (l [1, 2, 3])) == (l [2, 3])
  assert $ (deleteAt 1 (l [1, 2, 3])) == (l [1, 3])

  log "updateAt should replace an item at the specified index"
  assert $ (updateAt 0 9 (l [1, 2, 3])) == (l [9, 2, 3])
  assert $ (updateAt 1 9 (l [1, 2, 3])) == (l [1, 9, 3])

  log "modifyAt should update an item at the specified index"
  assert $ (modifyAt 0 (_ + 1) (l [1, 2, 3])) == (l [2, 2, 3])
  assert $ (modifyAt 1 (_ + 1) (l [1, 2, 3])) == (l [1, 3, 3])

  log "alterAt should update an item at the specified index when the function returns Just"
  assert $ (alterAt 0 (Just <<< (_ + 1)) (l [1, 2, 3])) == (l [2, 2, 3])
  assert $ (alterAt 1 (Just <<< (_ + 1)) (l [1, 2, 3])) == (l [1, 3, 3])

  log "alterAt should drop an item at the specified index when the function returns Nothing"
  assert $ (alterAt 0 (const Nothing) (l [1, 2, 3])) == (l [2, 3])
  assert $ (alterAt 1 (const Nothing) (l [1, 2, 3])) == (l [1, 3])

  log "reverse should reverse the order of items in an list"
  assert $ (reverse (l [1, 2, 3])) == l [3, 2, 1]
  assert $ (reverse nil') == nil'

  log "reverse should be stack-safe"
  assert $ head (reverse longList) == last longList

  log "concat should join an list of lists"
  assert $ (concat (l [l [1, 2], l [3, 4]])) == l [1, 2, 3, 4]
  assert $ (concat (l [l [1], nil'])) == l [1]
  assert $ (concat (l [nil', nil'])) == nil'

  log "concatMap should be equivalent to (concat <<< map)"
  assert $ concatMap doubleAndOrig (l [1, 2, 3]) == concat (map doubleAndOrig (l [1, 2, 3]))

  log "filter should remove items that don't match a predicate"
  assert $ filter odd (range 0 10) == l [1, 3, 5, 7, 9]

  log "filterM should remove items that don't match a predicate while using a monadic behaviour"
  assert $ filterM (Just <<< odd) (range 0 10) == Just (l [1, 3, 5, 7, 9])
  assert $ filterM (const Nothing) (repeat 0) == Nothing

  log "mapMaybe should transform every item in an list, throwing out Nothing values"
  assert $ mapMaybe (\x -> if x /= 0 then Just x else Nothing) (l [0, 1, 0, 0, 2, 3]) == l [1, 2, 3]

  log "catMaybe should take an list of Maybe values and throw out Nothings"
  assert $ catMaybes (l [Nothing, Just 2, Nothing, Just 4]) == l [2, 4]

  log "mapWithIndex should take a list of values and apply a function which also takes the index into account"
  assert $ mapWithIndex (\x ix -> x + ix) (fromFoldable [0, 1, 2, 3]) == fromFoldable [0, 2, 4, 6]
  assert $ map (mapWithIndex (\x ix -> x + ix)) (NEL.fromFoldable [0, 1, 2, 3]) == NEL.fromFoldable [0, 2, 4, 6]

  -- log "sort should reorder a list into ascending order based on the result of compare"
  -- assert $ sort (l [1, 3, 2, 5, 6, 4]) == l [1, 2, 3, 4, 5, 6]

  -- log "sortBy should reorder a list into ascending order based on the result of a comparison function"
  -- assert $ sortBy (flip compare) (l [1, 3, 2, 5, 6, 4]) == l [6, 5, 4, 3, 2, 1]

  log "slice should work on infinite lists"
  assert $ (slice 3 5 (repeat 0)) == l [0, 0]

  log "take should keep the specified number of items from the front of an list, discarding the rest"
  assert $ (take 1 (l [1, 2, 3])) == l [1]
  assert $ (take 2 (l [1, 2, 3])) == l [1, 2]
  assert $ (take 1 nil') == nil'

  log "take should evaluate exactly n items which we needed"
  assert let oops x = 0 : oops x
             xs = 1 : defer oops
          in take 1 xs == l [1]
  -- If `take` evaluate more than once, it would crash with a stack overflow

  log "takeWhile should keep all values that match a predicate from the front of an list"
  assert $ (takeWhile (_ /= 2) (l [1, 2, 3])) == l [1]
  assert $ (takeWhile (_ /= 3) (l [1, 2, 3])) == l [1, 2]
  assert $ (takeWhile (_ /= 1) nil') == nil'

  log "takeWhile should work on huge lists"
  assert $ (takeWhile (_ /= 3) (range 0 100000000)) == l [0, 1, 2]

  log "drop should remove the specified number of items from the front of an list"
  assert $ (drop 1 (l [1, 2, 3])) == l [2, 3]
  assert $ (drop 2 (l [1, 2, 3])) == l [3]
  assert $ (drop 1 nil') == nil'

  log "dropWhile should remove all values that match a predicate from the front of an list"
  assert $ (dropWhile (_ /= 1) (l [1, 2, 3])) == l [1, 2, 3]
  assert $ (dropWhile (_ /= 2) (l [1, 2, 3])) == l [2, 3]
  assert $ (dropWhile (_ /= 1) nil') == nil'

  log "span should split an list in two based on a predicate"
  let spanResult = span (_ < 4) (l [1, 2, 3, 4, 5, 6, 7])
  assert $ spanResult.init == l [1, 2, 3]
  assert $ spanResult.rest == l [4, 5, 6, 7]

  log "group should group consecutive equal elements into lists"
  assert $ group (l [1, 2, 2, 3, 3, 3, 1]) == l [NEL.singleton 1, nel (2 :| l [2]), nel (3 :| l [3, 3]), NEL.singleton 1]

  -- log "group' should sort then group consecutive equal elements into lists"
  -- assert $ group' (l [1, 2, 2, 3, 3, 3, 1]) == l [l [1, 1], l [2, 2], l [3, 3, 3]]

  log "groupBy should group consecutive equal elements into lists based on an equivalence relation"
  assert $ groupBy (\x y -> odd x && odd y) (l [1, 1, 2, 2, 3, 3]) == l [nel (1 :| l [1]), NEL.singleton 2, NEL.singleton 2, nel (3 :| l [3])]

  log "partition should separate a list into a tuple of lists that do and do not satisfy a predicate"
  let partitioned = partition (_ > 2) (l [1, 5, 3, 2, 4])
  assert $ partitioned.yes == l [5, 3, 4]
  assert $ partitioned.no == l [1, 2]

  log "iterate on nonempty lazy list should apply supplied function correctly"
  assert $ (take 3 $ NEL.toList $ NEL.iterate (_ + 1) 0) == l [0, 1, 2]

  log "nub should remove duplicate elements from the list, keeping the first occurence"
  assert $ nub (l [1, 2, 2, 3, 4, 1]) == l [1, 2, 3, 4]

  log "nubBy should remove duplicate items from the list using a supplied predicate"
  let nubPred = \x y -> if odd x then false else x == y
  assert $ nubBy nubPred (l [1, 2, 2, 3, 3, 4, 4, 1]) == l [1, 2, 3, 3, 4, 1]

  log "union should produce the union of two lists"
  assert $ union (l [1, 2, 3]) (l [2, 3, 4]) == l [1, 2, 3, 4]
  assert $ union (l [1, 1, 2, 3]) (l [2, 3, 4]) == l [1, 1, 2, 3, 4]

  log "unionBy should produce the union of two lists using the specified equality relation"
  assert $ unionBy (\_ y -> y < 5) (l [1, 2, 3]) (l [2, 3, 4, 5, 6]) == l [1, 2, 3, 5, 6]

  log "delete should remove the first matching item from an list"
  assert $ delete 1 (l [1, 2, 1]) == l [2, 1]
  assert $ delete 2 (l [1, 2, 1]) == l [1, 1]

  log "deleteBy should remove the first equality-relation-matching item from an list"
  assert $ deleteBy (/=) 2 (l [1, 2, 1]) == l [2, 1]
  assert $ deleteBy (/=) 1 (l [1, 2, 1]) == l [1, 1]

  log "(\\\\) should return the difference between two lists"
  assert $ l [1, 2, 3, 4, 3, 2, 1] \\ l [1, 1, 2, 3] == l [4, 3, 2]

  log "intersect should return the intersection of two lists"
  assert $ intersect (l [1, 2, 3, 4, 3, 2, 1]) (l [1, 1, 2, 3]) == l [1, 2, 3, 3, 2, 1]

  log "intersectBy should return the intersection of two lists using the specified equivalence relation"
  assert $ intersectBy (\x y -> (x * 2) == y) (l [1, 2, 3]) (l [2, 6]) == l [1, 3]

  log "repeat on non-empty lazy list should repeat element"
  assert $ (take 3 $ NEL.toList $ NEL.repeat 0) == l [0, 0, 0]

  log "zipWith should use the specified function to zip two lists together"
  assert $ zipWith (\x y -> l [show x, y]) (l [1, 2, 3]) (l ["a", "b", "c"]) == l [l ["1", "a"], l ["2", "b"], l ["3", "c"]]

  log "zipWithA should use the specified function to zip two lists together"
  assert $ zipWithA (\x y -> Just $ Tuple x y) (l [1, 2, 3]) (l ["a", "b", "c"]) == Just (l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"])

  log "zipWithA should work with infinite lists"
  assert $
    let inf = repeat 1
        ints = replicate 10 3
        zipped = zipWithA (\x y -> Just (x + y)) inf ints
     in map length zipped == pure (length ints)
  log "zip should use the specified function to zip two lists together"
  assert $ zip (l [1, 2, 3]) (l ["a", "b", "c"]) == l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"]

  log "unzip should deconstruct a list of tuples into a tuple of lists"
  assert $ unzip (l [Tuple 1 "a", Tuple 2 "b", Tuple 3 "c"]) == Tuple (l [1, 2, 3]) (l ["a", "b", "c"])

  log "foldM should perform a fold using a monadic step function"
  assert $ foldM (\x y -> Just (x + y)) 0 (range 1 10) == Just 55
  assert $ foldM (\_ _ -> Nothing) 0 (range 1 10) == Nothing

  log "foldM should work ok on infinite lists"
  assert let infs = iterate (_ + 1) 1
             f acc x = if x >= 10 then Nothing else Just (cons 0 acc)
          in foldM f nil infs == Nothing

  log "foldrLazy should work ok on infinite lists"
  assert let infs = iterate (_ + 1) 1
             infs' = foldrLazy cons nil infs
          in take 1000 infs == take 1000 infs'

  log "scanrLazy should work ok on infinite lists"
  assert let infs = iterate (_ + 1) 1
             infs' = scanrLazy (\i _ -> i) 0 infs
          in take 1000 infs == take 1000 infs'

  log "can find the first 10 primes using lazy lists"
  let eratos :: List Int -> List Int
      eratos xs = defer \_ ->
        case uncons xs of
          Nothing -> nil
          Just { head: p, tail: ys } -> p `cons` eratos (filter (\x -> x `mod` p /= 0) ys)

      upFrom = iterate (1 + _)

      primes = eratos $ upFrom 2
  assert $ take 10 primes == l [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

  log "transpose"
  assert $ transpose (l [l [1,2,3], l[4,5,6], l [7,8,9]]) ==
                     (l [l [1,4,7], l[2,5,8], l [3,6,9]])
  log "transpose skips elements when rows don't match"
  assert $ transpose ((10:11:nil) : (20:nil) : nil : (30:31:32:nil) : nil) ==
                     ((10:20:30:nil) : (11:31:nil) : (32:nil) : nil)
  log "transpose nil == nil"
  assert $ transpose nil == (nil :: List (List Int))

  log "transpose (singleton nil) == nil"
  assert $ transpose (singleton nil) == (nil :: List (List Int))

  log "unfoldr should maintain order"
  assert $ (1..5) == unfoldr step 1

  log "unfoldr1 should maintain order"
  assert $ (1..5) == unfoldr1 step1 1

  log "map should maintain order"
  assert $ (1..5) == map identity (1..5)

  log "unfoldable replicate1 should be stack-safe for NEL"
  void $ pure $ NEL.length $ (replicate1 100000 1 :: NEL.NonEmptyList Int)

  log "unfoldr1 should maintain order for NEL"
  assert $ (nel (1 :| l [2, 3, 4, 5])) == unfoldr1 step1 1

step :: Int -> Maybe (Tuple Int Int)
step 6 = Nothing
step n = Just (Tuple n (n + 1))

step1 :: Int -> Tuple Int (Maybe Int)
step1 n = Tuple n (if n >= 5 then Nothing else Just (n + 1))

nil' :: List Int
nil' = nil

odd :: Int -> Boolean
odd n = n `mod` 2 /= zero

doubleAndOrig :: Int -> List Int
doubleAndOrig x = cons (x * 2) (cons x nil)
