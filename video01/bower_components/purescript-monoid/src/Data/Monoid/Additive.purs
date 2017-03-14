module Data.Monoid.Additive where

import Prelude

import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Functor.Invariant (class Invariant)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype, unwrap)

-- | Monoid and semigroup for semirings under addition.
-- |
-- | ``` purescript
-- | Additive x <> Additive y == Additive (x + y)
-- | mempty :: Additive _ == Additive zero
-- | ```
newtype Additive a = Additive a

derive instance newtypeAdditive :: Newtype (Additive a) _

derive newtype instance eqAdditive :: Eq a => Eq (Additive a)

derive newtype instance ordAdditive :: Ord a => Ord (Additive a)

derive newtype instance boundedAdditive :: Bounded a => Bounded (Additive a)

instance functorAdditive :: Functor Additive where
  map f (Additive x) = Additive (f x)

instance invariantAdditive :: Invariant Additive where
  imap f _ (Additive x) = Additive (f x)

instance applyAdditive :: Apply Additive where
  apply (Additive f) (Additive x) = Additive (f x)

instance applicativeAdditive :: Applicative Additive where
  pure = Additive

instance bindAdditive :: Bind Additive where
  bind (Additive x) f = f x

instance monadAdditive :: Monad Additive

instance extendAdditive :: Extend Additive where
  extend f x = Additive (f x)

instance comonadAdditive :: Comonad Additive where
  extract = unwrap

instance showAdditive :: Show a => Show (Additive a) where
  show (Additive a) = "(Additive " <> show a <> ")"

instance semigroupAdditive :: Semiring a => Semigroup (Additive a) where
  append (Additive a) (Additive b) = Additive (a + b)

instance monoidAdditive :: Semiring a => Monoid (Additive a) where
  mempty = Additive zero
