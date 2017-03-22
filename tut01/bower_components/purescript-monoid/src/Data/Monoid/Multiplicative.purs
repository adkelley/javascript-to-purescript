module Data.Monoid.Multiplicative where

import Prelude

import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Functor.Invariant (class Invariant)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype, unwrap)

-- | Monoid and semigroup for semirings under multiplication.
-- |
-- | ``` purescript
-- | Multiplicative x <> Multiplicative y == Multiplicative (x * y)
-- | mempty :: Multiplicative _ == Multiplicative one
-- | ```
newtype Multiplicative a = Multiplicative a

derive instance newtypeMultiplicative :: Newtype (Multiplicative a) _

derive newtype instance eqMultiplicative :: Eq a => Eq (Multiplicative a)

derive newtype instance ordMultiplicative :: Ord a => Ord (Multiplicative a)

derive newtype instance boundedMultiplicative :: Bounded a => Bounded (Multiplicative a)

instance functorMultiplicative :: Functor Multiplicative where
  map f (Multiplicative x) = Multiplicative (f x)

instance invariantMultiplicative :: Invariant Multiplicative where
  imap f _ (Multiplicative x) = Multiplicative (f x)

instance applyMultiplicative :: Apply Multiplicative where
  apply (Multiplicative f) (Multiplicative x) = Multiplicative (f x)

instance applicativeMultiplicative :: Applicative Multiplicative where
  pure = Multiplicative

instance bindMultiplicative :: Bind Multiplicative where
  bind (Multiplicative x) f = f x

instance monadMultiplicative :: Monad Multiplicative

instance extendMultiplicative :: Extend Multiplicative where
  extend f x = Multiplicative (f x)

instance comonadMultiplicative :: Comonad Multiplicative where
  extract = unwrap

instance showMultiplicative :: (Show a) => Show (Multiplicative a) where
  show (Multiplicative a) = "(Multiplicative " <> show a <> ")"

instance semigroupMultiplicative :: (Semiring a) => Semigroup (Multiplicative a) where
  append (Multiplicative a) (Multiplicative b) = Multiplicative (a * b)

instance monoidMultiplicative :: (Semiring a) => Monoid (Multiplicative a) where
  mempty = Multiplicative one
