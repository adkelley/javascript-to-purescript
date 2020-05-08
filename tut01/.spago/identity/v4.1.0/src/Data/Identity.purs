module Data.Identity where

import Prelude

import Control.Alt (class Alt)
import Control.Comonad (class Comonad)
import Control.Extend (class Extend)
import Control.Lazy (class Lazy)
import Data.Eq (class Eq1)
import Data.Foldable (class Foldable)
import Data.FoldableWithIndex (class FoldableWithIndex)
import Data.Functor.Invariant (class Invariant, imapF)
import Data.FunctorWithIndex (class FunctorWithIndex)
import Data.Newtype (class Newtype)
import Data.Ord (class Ord1)
import Data.Semigroup.Foldable (class Foldable1)
import Data.Semigroup.Traversable (class Traversable1)
import Data.Traversable (class Traversable)
import Data.TraversableWithIndex (class TraversableWithIndex)

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

derive newtype instance lazyIdentity :: Lazy a => Lazy (Identity a)

instance showIdentity :: Show a => Show (Identity a) where
  show (Identity x) = "(Identity " <> show x <> ")"

derive instance eq1Identity :: Eq1 Identity

derive instance ord1Identity :: Ord1 Identity

derive instance functorIdentity :: Functor Identity

instance functorWithIndexIdentity :: FunctorWithIndex Unit Identity where
  mapWithIndex f (Identity a) = Identity (f unit a)

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

instance foldable1Identity :: Foldable1 Identity where
  fold1 (Identity x) = x
  foldMap1 f (Identity x) = f x

instance foldableWithIndexIdentity :: FoldableWithIndex Unit Identity where
  foldrWithIndex f z (Identity x) = f unit x z
  foldlWithIndex f z (Identity x) = f unit z x
  foldMapWithIndex f (Identity x) = f unit x

instance traversableIdentity :: Traversable Identity where
  traverse f (Identity x) = Identity <$> f x
  sequence (Identity x) = Identity <$> x

instance traversable1Identity :: Traversable1 Identity where
  traverse1 f (Identity x) = Identity <$> f x
  sequence1 (Identity x) = Identity <$> x

instance traversableWithIndexIdentity :: TraversableWithIndex Unit Identity where
  traverseWithIndex f (Identity x) = Identity <$> f unit x
