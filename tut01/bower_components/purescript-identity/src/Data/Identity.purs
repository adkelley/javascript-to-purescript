module Data.Identity where

import Prelude

import Control.Alt (class Alt)
import Control.Comonad (class Comonad)
import Control.Extend (class Extend)

import Data.Foldable (class Foldable)
import Data.Functor.Invariant (class Invariant, imapF)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype)
import Data.Traversable (class Traversable)

newtype Identity a = Identity a

derive instance newtypeIdentity :: Newtype (Identity a) _

derive newtype instance eqIdentity :: Eq a => Eq (Identity a)

derive newtype instance ordIdentity :: Ord a => Ord (Identity a)

derive newtype instance boundedIdentity :: Bounded a => Bounded (Identity a)

derive newtype instance heytingAlgebraIdentity :: HeytingAlgebra a => HeytingAlgebra (Identity a)

derive newtype instance booleanAlgebraIdentity :: BooleanAlgebra a => BooleanAlgebra (Identity a)

derive newtype instance semigroupIdenity :: Semigroup a => Semigroup (Identity a)

derive newtype instance monoidIdentity :: Monoid a => Monoid (Identity a)

derive newtype instance semiringIdentity :: Semiring a => Semiring (Identity a)

derive newtype instance euclideanRingIdentity :: EuclideanRing a => EuclideanRing (Identity a)

derive newtype instance ringIdentity :: Ring a => Ring (Identity a)

derive newtype instance commutativeRingIdentity :: CommutativeRing a => CommutativeRing (Identity a)

derive newtype instance fieldIdentity :: Field a => Field (Identity a)

instance showIdentity :: Show a => Show (Identity a) where
  show (Identity x) = "(Identity " <> show x <> ")"

instance functorIdentity :: Functor Identity where
  map f (Identity x) = Identity (f x)

instance invariantIdentity :: Invariant Identity where
  imap = imapF

instance altIdentity :: Alt Identity where
  alt x _ = x

instance applyIdentity :: Apply Identity where
  apply (Identity f) (Identity x) = Identity (f x)

instance applicativeIdentity :: Applicative Identity where
  pure = Identity

instance bindIdentity :: Bind Identity where
  bind (Identity m) f = f m

instance monadIdentity :: Monad Identity

instance extendIdentity :: Extend Identity where
  extend f m = Identity (f m)

instance comonadIdentity :: Comonad Identity where
  extract (Identity x) = x

instance foldableIdentity :: Foldable Identity where
  foldr f z (Identity x) = f x z
  foldl f z (Identity x) = f z x
  foldMap f (Identity x) = f x

instance traversableIdentity :: Traversable Identity where
  traverse f (Identity x) = Identity <$> f x
  sequence (Identity x) = Identity <$> x
