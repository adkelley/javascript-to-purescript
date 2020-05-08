module Data.Semigroup.Foldable
  ( class Foldable1
  , foldMap1
  , fold1
  , traverse1_
  , for1_
  , sequence1_
  , foldMap1Default
  , fold1Default
  , intercalate
  , intercalateMap
  , maximum
  , minimum
  ) where

import Prelude

import Data.Foldable (class Foldable)
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Multiplicative (Multiplicative(..))
import Data.Newtype (ala)
import Data.Ord.Max (Max(..))
import Data.Ord.Min (Min(..))

-- | `Foldable1` represents data structures with a minimum of one element that can be _folded_.
-- |
-- | - `fold1` folds a structure using a `Semigroup` instance
-- | - `foldMap1` folds a structure by accumulating values in a `Semigroup`
-- |
-- | Default implementations are provided by the following functions:
-- |
-- | - `fold1Default`
-- | - `foldMap1Default`
-- |
-- | Note: some combinations of the default implementations are unsafe to
-- | use together - causing a non-terminating mutually recursive cycle.
-- | These combinations are documented per function.
class Foldable t <= Foldable1 t where
  foldMap1 :: forall a m. Semigroup m => (a -> m) -> t a -> m
  fold1 :: forall m. Semigroup m => t m -> m

-- | A default implementation of `fold1` using `foldMap1`.
fold1Default :: forall t m. Foldable1 t => Semigroup m => t m -> m
fold1Default = foldMap1 identity

-- | A default implementation of `foldMap1` using `fold1`.
foldMap1Default :: forall t m a. Foldable1 t => Functor t => Semigroup m => (a -> m) -> t a -> m
foldMap1Default f = (map f) >>> fold1

instance foldableDual :: Foldable1 Dual where
  foldMap1 f (Dual x) = f x
  fold1 = fold1Default

instance foldableMultiplicative :: Foldable1 Multiplicative where
  foldMap1 f (Multiplicative x) = f x
  fold1 = fold1Default

newtype Act f a = Act (f a)

getAct :: forall f a. Act f a -> f a
getAct (Act f) = f

instance semigroupAct :: Apply f => Semigroup (Act f a) where
  append (Act a) (Act b) = Act (a *> b)

-- | Traverse a data structure, performing some effects encoded by an
-- | `Apply` instance at each value, ignoring the final result.
traverse1_ :: forall t f a b. Foldable1 t => Apply f => (a -> f b) -> t a -> f Unit
traverse1_ f t = unit <$ getAct (foldMap1 (Act <<< f) t)

-- | A version of `traverse1_` with its arguments flipped.
-- |
-- | This can be useful when running an action written using do notation
-- | for every element in a data structure:
for1_ :: forall t f a b. Foldable1 t => Apply f => t a -> (a -> f b) -> f Unit
for1_ = flip traverse1_

-- | Perform all of the effects in some data structure in the order
-- | given by the `Foldable1` instance, ignoring the final result.
sequence1_ :: forall t f a. Foldable1 t => Apply f => t (f a) -> f Unit
sequence1_ = traverse1_ identity

maximum :: forall f a. Ord a => Foldable1 f => f a -> a
maximum = ala Max foldMap1

minimum :: forall f a. Ord a => Foldable1 f => f a -> a
minimum = ala Min foldMap1

-- | Internal. Used by intercalation functions.
newtype JoinWith a = JoinWith (a -> a)

joinee :: forall a. JoinWith a -> a -> a
joinee (JoinWith x) = x

instance semigroupJoinWith :: Semigroup a => Semigroup (JoinWith a) where
  append (JoinWith a) (JoinWith b) = JoinWith $ \j -> a j <> j <> b j

-- | Fold a data structure using a `Semigroup` instance,
-- | combining adjacent elements using the specified separator.
intercalate :: forall f m. Foldable1 f => Semigroup m => m -> f m -> m
intercalate = flip intercalateMap identity

-- | Fold a data structure, accumulating values in some `Semigroup`,
-- | combining adjacent elements using the specified separator.
intercalateMap
  :: forall f m a
   . Foldable1 f
  => Semigroup m
  => m -> (a -> m) -> f a -> m
intercalateMap j f foldable =
  joinee (foldMap1 (JoinWith <<< const <<< f) foldable) j
