module Data.FunctorWithIndex
  ( class FunctorWithIndex, mapWithIndex, mapDefault
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Maybe.First (First)
import Data.Maybe.Last (Last)
import Data.Monoid.Additive (Additive)
import Data.Monoid.Conj (Conj)
import Data.Monoid.Disj (Disj)
import Data.Monoid.Dual (Dual)
import Data.Monoid.Multiplicative (Multiplicative)

-- | A `Functor` with an additional index.
-- | Instances must satisfy a modified form of the `Functor` laws
-- | ```purescript
-- | mapWithIndex (\_ a -> a) = identity
-- | mapWithIndex f . mapWithIndex g = mapWithIndex (\i -> f i <<< g i)
-- | ```
-- | and be compatible with the `Functor` instance
-- | ```purescript
-- | map f = mapWithIndex (const f)
-- | ```
class Functor f <= FunctorWithIndex i f | f -> i where
  mapWithIndex :: forall a b. (i -> a -> b) -> f a -> f b

foreign import mapWithIndexArray :: forall i a b. (i -> a -> b) -> Array a -> Array b

instance functorWithIndexArray :: FunctorWithIndex Int Array where
  mapWithIndex = mapWithIndexArray

instance functorWithIndexMaybe :: FunctorWithIndex Unit Maybe where
  mapWithIndex f = map $ f unit

instance functorWithIndexFirst :: FunctorWithIndex Unit First where
  mapWithIndex f = map $ f unit

instance functorWithIndexLast :: FunctorWithIndex Unit Last where
  mapWithIndex f = map $ f unit

instance functorWithIndexAdditive :: FunctorWithIndex Unit Additive where
  mapWithIndex f = map $ f unit

instance functorWithIndexDual :: FunctorWithIndex Unit Dual where
  mapWithIndex f = map $ f unit

instance functorWithIndexConj :: FunctorWithIndex Unit Conj where
  mapWithIndex f = map $ f unit

instance functorWithIndexDisj :: FunctorWithIndex Unit Disj where
  mapWithIndex f = map $ f unit

instance functorWithIndexMultiplicative :: FunctorWithIndex Unit Multiplicative where
  mapWithIndex f = map $ f unit

-- | A default implementation of Functor's `map` in terms of `mapWithIndex`
mapDefault :: forall i f a b. FunctorWithIndex i f => (a -> b) -> f a -> f b
mapDefault f = mapWithIndex (const f)
