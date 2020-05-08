-- | This module defines a generic non-empty data structure, which adds an
-- | additional element to any container type.
module Data.NonEmpty
  ( NonEmpty(..)
  , singleton
  , (:|)
  , foldl1
  , fromNonEmpty
  , oneOf
  , head
  , tail
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Alternative (class Alternative)
import Control.Plus (class Plus, empty)
import Data.Eq (class Eq1)
import Data.Foldable (class Foldable, foldl, foldr, foldMap)
import Data.FoldableWithIndex (class FoldableWithIndex, foldMapWithIndex, foldlWithIndex, foldrWithIndex)
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Maybe (Maybe(..))
import Data.Ord (class Ord1)
import Data.Semigroup.Foldable (class Foldable1, foldMap1)
import Data.Traversable (class Traversable, traverse, sequence)
import Data.TraversableWithIndex (class TraversableWithIndex, traverseWithIndex)
import Data.Tuple (uncurry)
import Data.Unfoldable (class Unfoldable, unfoldr)
import Data.Unfoldable1 (class Unfoldable1)

-- | A non-empty container of elements of type a.
-- |
-- | For example:
-- |
-- | ```purescript
-- | nonEmptyList :: NonEmpty List Int
-- | nonEmptyList = 0 :| empty
-- | ```
data NonEmpty f a = NonEmpty a (f a)

-- | An infix synonym for `NonEmpty`.
infixr 5 NonEmpty as :|

-- | Create a non-empty structure with a single value.
singleton :: forall f a. Plus f => a -> NonEmpty f a
singleton a = a :| empty

-- | Fold a non-empty structure, collecting results using a binary operation.
foldl1 :: forall f a. Foldable f => (a -> a -> a) -> NonEmpty f a -> a
foldl1 f (a :| fa) = foldl f a fa

fromNonEmpty :: forall f a r. (a -> f a -> r) -> NonEmpty f a -> r
fromNonEmpty f (a :| fa) = a `f` fa

oneOf :: forall f a. Alternative f => NonEmpty f a -> f a
oneOf (a :| fa) = pure a <|> fa

-- | Get the 'first' element of a non-empty container.
head :: forall f a. NonEmpty f a -> a
head (x :| _) = x

-- | Get everything but the 'first' element of a non-empty container.
tail :: forall f a. NonEmpty f a -> f a
tail (_ :| xs) = xs

instance showNonEmpty :: (Show a, Show (f a)) => Show (NonEmpty f a) where
  show (a :| fa) = "(NonEmpty " <> show a <> " " <> show fa <> ")"

derive instance eqNonEmpty :: (Eq1 f, Eq a) => Eq (NonEmpty f a)

derive instance eq1NonEmpty :: Eq1 f => Eq1 (NonEmpty f)

derive instance ordNonEmpty :: (Ord1 f, Ord a) => Ord (NonEmpty f a)

derive instance ord1NonEmpty :: Ord1 f => Ord1 (NonEmpty f)

derive instance functorNonEmpty :: Functor f => Functor (NonEmpty f)

instance functorWithIndex
  :: FunctorWithIndex i f
  => FunctorWithIndex (Maybe i) (NonEmpty f) where
  mapWithIndex f (a :| fa) = f Nothing a :| mapWithIndex (f <<< Just) fa

instance foldableNonEmpty :: Foldable f => Foldable (NonEmpty f) where
  foldMap f (a :| fa) = f a <> foldMap f fa
  foldl f b (a :| fa) = foldl f (f b a) fa
  foldr f b (a :| fa) = f a (foldr f b fa)

instance foldableWithIndexNonEmpty
  :: (FoldableWithIndex i f)
  => FoldableWithIndex (Maybe i) (NonEmpty f) where
  foldMapWithIndex f (a :| fa) = f Nothing a <> foldMapWithIndex (f <<< Just) fa
  foldlWithIndex f b (a :| fa) = foldlWithIndex (f <<< Just) (f Nothing b a) fa
  foldrWithIndex f b (a :| fa) = f Nothing a (foldrWithIndex (f <<< Just) b fa)

instance traversableNonEmpty :: Traversable f => Traversable (NonEmpty f) where
  sequence (a :| fa) = NonEmpty <$> a <*> sequence fa
  traverse f (a :| fa) = NonEmpty <$> f a <*> traverse f fa

instance traversableWithIndexNonEmpty
  :: (TraversableWithIndex i f)
  => TraversableWithIndex (Maybe i) (NonEmpty f) where
  traverseWithIndex f (a :| fa) =
    NonEmpty <$> f Nothing a <*> traverseWithIndex (f <<< Just) fa

instance foldable1NonEmpty :: Foldable f => Foldable1 (NonEmpty f) where
  fold1 = foldMap1 identity
  foldMap1 f (a :| fa) = foldl (\s a1 -> s <> f a1) (f a) fa

instance unfoldable1NonEmpty :: Unfoldable f => Unfoldable1 (NonEmpty f) where
  unfoldr1 f b = uncurry (:|) $ unfoldr (map f) <$> f b
