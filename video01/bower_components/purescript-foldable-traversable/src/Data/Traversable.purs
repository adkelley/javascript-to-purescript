module Data.Traversable
  ( class Traversable, traverse, sequence
  , traverseDefault, sequenceDefault
  , for
  , Accum
  , scanl
  , scanr
  , mapAccumL
  , mapAccumR
  , module Data.Foldable
  ) where

import Prelude

import Data.Foldable (class Foldable, all, and, any, elem, find, fold, foldMap, foldMapDefaultL, foldMapDefaultR, foldl, foldlDefault, foldr, foldrDefault, for_, intercalate, maximum, maximumBy, minimum, minimumBy, notElem, oneOf, or, product, sequence_, sum, traverse_)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Maybe.Last (Last(..))
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Multiplicative (Multiplicative(..))

-- | `Traversable` represents data structures which can be _traversed_,
-- | accumulating results and effects in some `Applicative` functor.
-- |
-- | - `traverse` runs an action for every element in a data structure,
-- |   and accumulates the results.
-- | - `sequence` runs the actions _contained_ in a data structure,
-- |   and accumulates the results.
-- |
-- | The `traverse` and `sequence` functions should be compatible in the
-- | following sense:
-- |
-- | - `traverse f xs = sequence (f <$> xs)`
-- | - `sequence = traverse id`
-- |
-- | `Traversable` instances should also be compatible with the corresponding
-- | `Foldable` instances, in the following sense:
-- |
-- | - `foldMap f = runConst <<< traverse (Const <<< f)`
-- |
-- | Default implementations are provided by the following functions:
-- |
-- | - `traverseDefault`
-- | - `sequenceDefault`
class (Functor t, Foldable t) <= Traversable t where
  traverse :: forall a b m. Applicative m => (a -> m b) -> t a -> m (t b)
  sequence :: forall a m. Applicative m => t (m a) -> m (t a)

-- | A default implementation of `traverse` using `sequence` and `map`.
traverseDefault
  :: forall t a b m
   . (Traversable t, Applicative m)
  => (a -> m b)
  -> t a
  -> m (t b)
traverseDefault f ta = sequence (f <$> ta)

-- | A default implementation of `sequence` using `traverse`.
sequenceDefault
  :: forall t a m
   . (Traversable t, Applicative m)
  => t (m a)
  -> m (t a)
sequenceDefault tma = traverse id tma

instance traversableArray :: Traversable Array where
  traverse = traverseArrayImpl apply map pure
  sequence = sequenceDefault

foreign import traverseArrayImpl
  :: forall m a b
   . (m (a -> b) -> m a -> m b)
  -> ((a -> b) -> m a -> m b)
  -> (a -> m a)
  -> (a -> m b)
  -> Array a
  -> m (Array b)

instance traversableMaybe :: Traversable Maybe where
  traverse _ Nothing  = pure Nothing
  traverse f (Just x) = Just <$> f x
  sequence Nothing  = pure Nothing
  sequence (Just x) = Just <$> x

instance traversableFirst :: Traversable First where
  traverse f (First x) = First <$> traverse f x
  sequence (First x) = First <$> sequence x

instance traversableLast :: Traversable Last where
  traverse f (Last x) = Last <$> traverse f x
  sequence (Last x) = Last <$> sequence x

instance traversableAdditive :: Traversable Additive where
  traverse f (Additive x) = Additive <$> f x
  sequence (Additive x) = Additive <$> x

instance traversableDual :: Traversable Dual where
  traverse f (Dual x) = Dual <$> f x
  sequence (Dual x) = Dual <$> x

instance traversableConj :: Traversable Conj where
  traverse f (Conj x) = Conj <$> f x
  sequence (Conj x) = Conj <$> x

instance traversableDisj :: Traversable Disj where
  traverse f (Disj x) = Disj <$> f x
  sequence (Disj x) = Disj <$> x

instance traversableMultiplicative :: Traversable Multiplicative where
  traverse f (Multiplicative x) = Multiplicative <$> f x
  sequence (Multiplicative x) = Multiplicative <$> x

-- | A version of `traverse` with its arguments flipped.
-- |
-- |
-- | This can be useful when running an action written using do notation
-- | for every element in a data structure:
-- |
-- | For example:
-- |
-- | ```purescript
-- | for [1, 2, 3] \n -> do
-- |   print n
-- |   return (n * n)
-- | ```
for
  :: forall a b m t
   . (Applicative m, Traversable t)
  => t a
  -> (a -> m b)
  -> m (t b)
for x f = traverse f x

type Accum s a = { accum :: s, value :: a }

newtype StateL s a = StateL (s -> Accum s a)

stateL :: forall s a. StateL s a -> s -> Accum s a
stateL (StateL k) = k

instance functorStateL :: Functor (StateL s) where
  map f k = StateL \s -> case stateL k s of
    { accum: s1, value: a } -> { accum: s1, value: f a }

instance applyStateL :: Apply (StateL s) where
  apply f x = StateL \s -> case stateL f s of
    { accum: s1, value: f' } -> case stateL x s1 of
      { accum: s2, value: x' } -> { accum: s2, value: f' x' }

instance applicativeStateL :: Applicative (StateL s) where
  pure a = StateL \s -> { accum: s, value: a }

-- | Fold a data structure from the left, keeping all intermediate results
-- | instead of only the final result. Note that the initial value does not
-- | appear in the result (unlike Haskell's `Prelude.scanl`).
-- |
-- | ```purescript
-- | scanl (+) 0  [1,2,3] = [1,3,6]
-- | scanl (-) 10 [1,2,3] = [9,7,4]
-- | ```
scanl :: forall a b f. Traversable f => (b -> a -> b) -> b -> f a -> f b
scanl f b0 xs = (mapAccumL (\b a -> let b' = f b a in { accum: b', value: b' }) b0 xs).value

-- | Fold a data structure from the left, keeping all intermediate results
-- | instead of only the final result.
-- |
-- | Unlike `scanl`, `mapAccumL` allows the type of accumulator to differ
-- | from the element type of the final data structure.
mapAccumL
  :: forall a b s f
   . (Traversable f)
  => (s -> a -> Accum s b)
  -> s
  -> f a
  -> Accum s (f b)
mapAccumL f s0 xs = stateL (traverse (\a -> StateL \s -> f s a) xs) s0

newtype StateR s a = StateR (s -> Accum s a)

stateR :: forall s a. StateR s a -> s -> Accum s a
stateR (StateR k) = k

instance functorStateR :: Functor (StateR s) where
  map f k = StateR \s -> case stateR k s of
    { accum: s1, value: a } -> { accum: s1, value: f a }

instance applyStateR :: Apply (StateR s) where
  apply f x = StateR \s -> case stateR x s of
    { accum: s1, value: x' } -> case stateR f s1 of
      { accum: s2, value: f' } -> { accum: s2, value: f' x' }

instance applicativeStateR :: Applicative (StateR s) where
  pure a = StateR \s -> { accum: s, value: a }

-- | Fold a data structure from the right, keeping all intermediate results
-- | instead of only the final result. Note that the initial value does not
-- | appear in the result (unlike Haskell's `Prelude.scanr`).
-- |
-- | ```purescript
-- | scanr (+) 0  [1,2,3] = [1,3,6]
-- | scanr (flip (-)) 10 [1,2,3] = [4,5,7]
-- | ```
scanr :: forall a b f. Traversable f => (a -> b -> b) -> b -> f a -> f b
scanr f b0 xs = (mapAccumR (\b a -> let b' = f a b in { accum: b', value: b' }) b0 xs).value

-- | Fold a data structure from the right, keeping all intermediate results
-- | instead of only the final result.
-- |
-- | Unlike `scanr`, `mapAccumR` allows the type of accumulator to differ
-- | from the element type of the final data structure.
mapAccumR
  :: forall a b s f
   . Traversable f
  => (s -> a -> Accum s b)
  -> s
  -> f a
  -> Accum s (f b)
mapAccumR f s0 xs = stateR (traverse (\a -> StateR \s -> f s a) xs) s0
