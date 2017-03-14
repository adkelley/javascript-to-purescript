module Data.Monoid.Disj where

import Prelude

import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Functor.Invariant (class Invariant)
import Data.HeytingAlgebra (ff, tt)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype, unwrap)

-- | Monoid under disjuntion.
-- |
-- | ``` purescript
-- | Disj x <> Disj y == Disj (x || y)
-- | mempty :: Disj _ == Disj bottom
-- | ```
newtype Disj a = Disj a

derive instance newtypeDisj :: Newtype (Disj a) _

derive newtype instance eqDisj :: Eq a => Eq (Disj a)

derive newtype instance ordDisj :: Ord a => Ord (Disj a)

derive newtype instance boundedDisj :: Bounded a => Bounded (Disj a)

instance functorDisj :: Functor Disj where
  map f (Disj x) = Disj (f x)

instance invariantDisj :: Invariant Disj where
  imap f _ (Disj x) = Disj (f x)

instance applyDisj :: Apply Disj where
  apply (Disj f) (Disj x) = Disj (f x)

instance applicativeDisj :: Applicative Disj where
  pure = Disj

instance bindDisj :: Bind Disj where
  bind (Disj x) f = f x

instance monadDisj :: Monad Disj

instance extendDisj :: Extend Disj where
  extend f x = Disj (f x)

instance comonadDisj :: Comonad Disj where
  extract = unwrap

instance showDisj :: Show a => Show (Disj a) where
  show (Disj a) = "(Disj " <> show a <> ")"

instance semigroupDisj :: HeytingAlgebra a => Semigroup (Disj a) where
  append (Disj a) (Disj b) = Disj (disj a b)

instance monoidDisj :: HeytingAlgebra a => Monoid (Disj a) where
  mempty = Disj ff

instance semiringDisj :: HeytingAlgebra a => Semiring (Disj a) where
  zero = Disj ff
  one = Disj tt
  add (Disj a) (Disj b) = Disj (disj a b)
  mul (Disj a) (Disj b) = Disj (conj a b)
