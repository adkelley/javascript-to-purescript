module Data.Monoid.Conj where

import Prelude

import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Functor.Invariant (class Invariant)
import Data.HeytingAlgebra (ff, tt)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype, unwrap)

-- | Monoid under conjuntion.
-- |
-- | ``` purescript
-- | Conj x <> Conj y == Conj (x && y)
-- | mempty :: Conj _ == Conj top
-- | ```
newtype Conj a = Conj a

derive instance newtypeConj :: Newtype (Conj a) _

derive newtype instance eqConj :: Eq a => Eq (Conj a)

derive newtype instance ordConj :: Ord a => Ord (Conj a)

derive newtype instance boundedConj :: Bounded a => Bounded (Conj a)

instance functorConj :: Functor Conj where
  map f (Conj x) = Conj (f x)

instance invariantConj :: Invariant Conj where
  imap f _ (Conj x) = Conj (f x)

instance applyConj :: Apply Conj where
  apply (Conj f) (Conj x) = Conj (f x)

instance applicativeConj :: Applicative Conj where
  pure = Conj

instance bindConj :: Bind Conj where
  bind (Conj x) f = f x

instance monadConj :: Monad Conj

instance extendConj :: Extend Conj where
  extend f x = Conj (f x)

instance comonadConj :: Comonad Conj where
  extract = unwrap

instance showConj :: (Show a) => Show (Conj a) where
  show (Conj a) = "(Conj " <> show a <> ")"

instance semigroupConj :: HeytingAlgebra a => Semigroup (Conj a) where
  append (Conj a) (Conj b) = Conj (conj a b)

instance monoidConj :: HeytingAlgebra a => Monoid (Conj a) where
  mempty = Conj tt

instance semiringConj :: HeytingAlgebra a => Semiring (Conj a) where
  zero = Conj tt
  one = Conj ff
  add (Conj a) (Conj b) = Conj (conj a b)
  mul (Conj a) (Conj b) = Conj (disj a b)
