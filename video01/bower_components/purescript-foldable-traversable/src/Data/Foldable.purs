module Data.Foldable
  ( class Foldable, foldr, foldl, foldMap
  , foldrDefault, foldlDefault, foldMapDefaultL, foldMapDefaultR
  , fold
  , traverse_
  , for_
  , sequence_
  , oneOf
  , intercalate
  , and
  , or
  , all
  , any
  , sum
  , product
  , elem
  , notElem
  , find
  , findMap
  , maximum
  , maximumBy
  , minimum
  , minimumBy
  ) where

import Prelude

import Control.Plus (class Plus, alt, empty)

import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Maybe.Last (Last(..))
import Data.Monoid (class Monoid, mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Endo (Endo(..))
import Data.Monoid.Multiplicative (Multiplicative(..))
import Data.Newtype (alaF, unwrap)

-- | `Foldable` represents data structures which can be _folded_.
-- |
-- | - `foldr` folds a structure from the right
-- | - `foldl` folds a structure from the left
-- | - `foldMap` folds a structure by accumulating values in a `Monoid`
-- |
-- | Default implementations are provided by the following functions:
-- |
-- | - `foldrDefault`
-- | - `foldlDefault`
-- | - `foldMapDefaultR`
-- | - `foldMapDefaultL`
-- |
-- | Note: some combinations of the default implementations are unsafe to
-- | use together - causing a non-terminating mutually recursive cycle.
-- | These combinations are documented per function.
class Foldable f where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b
  foldl :: forall a b. (b -> a -> b) -> b -> f a -> b
  foldMap :: forall a m. Monoid m => (a -> m) -> f a -> m

-- | A default implementation of `foldr` using `foldMap`.
-- |
-- | Note: when defining a `Foldable` instance, this function is unsafe to use
-- | in combination with `foldMapDefaultR`.
foldrDefault
  :: forall f a b
   . Foldable f
  => (a -> b -> b)
  -> b
  -> f a
  -> b
foldrDefault c u xs = unwrap (foldMap (Endo <<< c) xs) u

-- | A default implementation of `foldl` using `foldMap`.
-- |
-- | Note: when defining a `Foldable` instance, this function is unsafe to use
-- | in combination with `foldMapDefaultL`.
foldlDefault
  :: forall f a b
   . Foldable f
   => (b -> a -> b)
   -> b
   -> f a
   -> b
foldlDefault c u xs = unwrap (unwrap (foldMap (Dual <<< Endo <<< flip c) xs)) u

-- | A default implementation of `foldMap` using `foldr`.
-- |
-- | Note: when defining a `Foldable` instance, this function is unsafe to use
-- | in combination with `foldrDefault`.
foldMapDefaultR
  :: forall f a m
   . (Foldable f, Monoid m)
   => (a -> m)
   -> f a
   -> m
foldMapDefaultR f xs = foldr (\x acc -> f x <> acc) mempty xs

-- | A default implementation of `foldMap` using `foldl`.
-- |
-- | Note: when defining a `Foldable` instance, this function is unsafe to use
-- | in combination with `foldlDefault`.
foldMapDefaultL
  :: forall f a m
   . (Foldable f, Monoid m)
   => (a -> m)
   -> f a
   -> m
foldMapDefaultL f xs = foldl (\acc x -> f x <> acc) mempty xs

instance foldableArray :: Foldable Array where
  foldr = foldrArray
  foldl = foldlArray
  foldMap = foldMapDefaultR

foreign import foldrArray :: forall a b. (a -> b -> b) -> b -> Array a -> b
foreign import foldlArray :: forall a b. (b -> a -> b) -> b -> Array a -> b

instance foldableMaybe :: Foldable Maybe where
  foldr _ z Nothing  = z
  foldr f z (Just x) = x `f` z
  foldl _ z Nothing  = z
  foldl f z (Just x) = z `f` x
  foldMap f Nothing  = mempty
  foldMap f (Just x) = f x

instance foldableFirst :: Foldable First where
  foldr f z (First x) = foldr f z x
  foldl f z (First x) = foldl f z x
  foldMap f (First x) = foldMap f x

instance foldableLast :: Foldable Last where
  foldr f z (Last x) = foldr f z x
  foldl f z (Last x) = foldl f z x
  foldMap f (Last x) = foldMap f x

instance foldableAdditive :: Foldable Additive where
  foldr f z (Additive x) = x `f` z
  foldl f z (Additive x) = z `f` x
  foldMap f (Additive x) = f x

instance foldableDual :: Foldable Dual where
  foldr f z (Dual x) = x `f` z
  foldl f z (Dual x) = z `f` x
  foldMap f (Dual x) = f x

instance foldableDisj :: Foldable Disj where
  foldr f z (Disj x) = f x z
  foldl f z (Disj x) = f z x
  foldMap f (Disj x) = f x

instance foldableConj :: Foldable Conj where
  foldr f z (Conj x) = f x z
  foldl f z (Conj x) = f z x
  foldMap f (Conj x) = f x

instance foldableMultiplicative :: Foldable Multiplicative where
  foldr f z (Multiplicative x) = x `f` z
  foldl f z (Multiplicative x) = z `f` x
  foldMap f (Multiplicative x) = f x

-- | Fold a data structure, accumulating values in some `Monoid`.
fold :: forall f m. (Foldable f, Monoid m) => f m -> m
fold = foldMap id

-- | Traverse a data structure, performing some effects encoded by an
-- | `Applicative` functor at each value, ignoring the final result.
-- |
-- | For example:
-- |
-- | ```purescript
-- | traverse_ print [1, 2, 3]
-- | ```
traverse_
  :: forall a b f m
   . (Applicative m, Foldable f)
  => (a -> m b)
  -> f a
  -> m Unit
traverse_ f = foldr ((*>) <<< f) (pure unit)

-- | A version of `traverse_` with its arguments flipped.
-- |
-- | This can be useful when running an action written using do notation
-- | for every element in a data structure:
-- |
-- | For example:
-- |
-- | ```purescript
-- | for_ [1, 2, 3] \n -> do
-- |   print n
-- |   trace "squared is"
-- |   print (n * n)
-- | ```
for_
  :: forall a b f m
   . (Applicative m, Foldable f)
  => f a
  -> (a -> m b)
  -> m Unit
for_ = flip traverse_

-- | Perform all of the effects in some data structure in the order
-- | given by the `Foldable` instance, ignoring the final result.
-- |
-- | For example:
-- |
-- | ```purescript
-- | sequence_ [ trace "Hello, ", trace " world!" ]
-- | ```
sequence_ :: forall a f m. (Applicative m, Foldable f) => f (m a) -> m Unit
sequence_ = traverse_ id

-- | Combines a collection of elements using the `Alt` operation.
oneOf :: forall f g a. (Foldable f, Plus g) => f (g a) -> g a
oneOf = foldr alt empty

-- | Fold a data structure, accumulating values in some `Monoid`,
-- | combining adjacent elements using the specified separator.
intercalate :: forall f m. (Foldable f, Monoid m) => m -> f m -> m
intercalate sep xs = (foldl go { init: true, acc: mempty } xs).acc
  where
  go { init: true } x = { init: false, acc: x }
  go { acc: acc }   x = { init: false, acc: acc <> sep <> x }

-- | The conjunction of all the values in a data structure. When specialized
-- | to `Boolean`, this function will test whether all of the values in a data
-- | structure are `true`.
and :: forall a f. (Foldable f, HeytingAlgebra a) => f a -> a
and = all id

-- | The disjunction of all the values in a data structure. When specialized
-- | to `Boolean`, this function will test whether any of the values in a data
-- | structure is `true`.
or :: forall a f. (Foldable f, HeytingAlgebra a) => f a -> a
or = any id

-- | `all f` is the same as `and <<< map f`; map a function over the structure,
-- | and then get the conjunction of the results.
all :: forall a b f. (Foldable f, HeytingAlgebra b) => (a -> b) -> f a -> b
all p = alaF Conj foldMap p

-- | `any f` is the same as `or <<< map f`; map a function over the structure,
-- | and then get the disjunction of the results.
any :: forall a b f. (Foldable f, HeytingAlgebra b) => (a -> b) -> f a -> b
any p = alaF Disj foldMap p

-- | Find the sum of the numeric values in a data structure.
sum :: forall a f. (Foldable f, Semiring a) => f a -> a
sum = foldl (+) zero

-- | Find the product of the numeric values in a data structure.
product :: forall a f. (Foldable f, Semiring a) => f a -> a
product = foldl (*) one

-- | Test whether a value is an element of a data structure.
elem :: forall a f. (Foldable f, Eq a) => a -> f a -> Boolean
elem = any <<< (==)

-- | Test whether a value is not an element of a data structure.
notElem :: forall a f. (Foldable f, Eq a) => a -> f a -> Boolean
notElem x = not <<< elem x

-- | Try to find an element in a data structure which satisfies a predicate.
find :: forall a f. Foldable f => (a -> Boolean) -> f a -> Maybe a
find p = foldl go Nothing
  where
  go Nothing x | p x = Just x
  go r _ = r

-- | Try to find an element in a data structure which satisfies a predicate mapping.
findMap :: forall a b f. Foldable f => (a -> Maybe b) -> f a -> Maybe b
findMap p = foldl go Nothing
  where
  go Nothing x = p x
  go r _ = r

-- | Find the largest element of a structure, according to its `Ord` instance.
maximum :: forall a f. (Ord a, Foldable f) => f a -> Maybe a
maximum = maximumBy compare

-- | Find the largest element of a structure, according to a given comparison
-- | function. The comparison function should represent a total ordering (see
-- | the `Ord` type class laws); if it does not, the behaviour is undefined.
maximumBy :: forall a f. Foldable f => (a -> a -> Ordering) -> f a -> Maybe a
maximumBy cmp = foldl max' Nothing
  where
  max' Nothing x  = Just x
  max' (Just x) y = Just (if cmp x y == GT then x else y)

-- | Find the smallest element of a structure, according to its `Ord` instance.
minimum :: forall a f. (Ord a, Foldable f) => f a -> Maybe a
minimum = minimumBy compare

-- | Find the smallest element of a structure, according to a given comparison
-- | function. The comparison function should represent a total ordering (see
-- | the `Ord` type class laws); if it does not, the behaviour is undefined.
minimumBy :: forall a f. Foldable f => (a -> a -> Ordering) -> f a -> Maybe a
minimumBy cmp = foldl min' Nothing
  where
  min' Nothing x  = Just x
  min' (Just x) y = Just (if cmp x y == LT then x else y)
