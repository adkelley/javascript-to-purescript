module Data.Monoid.Dual where

import Prelude

import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Functor.Invariant (class Invariant)
import Data.Monoid (class Monoid, mempty)
import Data.Newtype (class Newtype, unwrap)

-- | The dual of a monoid.
-- |
-- | ``` purescript
-- | Dual x <> Dual y == Dual (y <> x)
-- | mempty :: Dual _ == Dual mempty
-- | ```
newtype Dual a = Dual a

derive instance newtypeDual :: Newtype (Dual a) _

derive newtype instance eqDual :: Eq a => Eq (Dual a)

derive newtype instance ordDual :: Ord a => Ord (Dual a)

derive newtype instance boundedDual :: Bounded a => Bounded (Dual a)

instance functorDual :: Functor Dual where
  map f (Dual x) = Dual (f x)

instance invariantDual :: Invariant Dual where
  imap f _ (Dual x) = Dual (f x)

instance applyDual :: Apply Dual where
  apply (Dual f) (Dual x) = Dual (f x)

instance applicativeDual :: Applicative Dual where
  pure = Dual

instance bindDual :: Bind Dual where
  bind (Dual x) f = f x

instance monadDual :: Monad Dual

instance extendDual :: Extend Dual where
  extend f x = Dual (f x)

instance comonadDual :: Comonad Dual where
  extract = unwrap

instance showDual :: Show a => Show (Dual a) where
  show (Dual a) = "(Dual " <> show a <> ")"

instance semigroupDual :: Semigroup a => Semigroup (Dual a) where
  append (Dual x) (Dual y) = Dual (y <> x)

instance monoidDual :: Monoid a => Monoid (Dual a) where
  mempty = Dual mempty
