module Data.Array.NonEmpty.Internal (NonEmptyArray) where

import Prelude

import Control.Alt (class Alt)
import Data.Eq (class Eq1)
import Data.Foldable (class Foldable)
import Data.FoldableWithIndex (class FoldableWithIndex)
import Data.FunctorWithIndex (class FunctorWithIndex)
import Data.Ord (class Ord1)
import Data.Semigroup.Foldable (class Foldable1, foldMap1Default)
import Data.Semigroup.Traversable (class Traversable1, sequence1Default)
import Data.Traversable (class Traversable)
import Data.TraversableWithIndex (class TraversableWithIndex)
import Data.Unfoldable1 (class Unfoldable1)

newtype NonEmptyArray a = NonEmptyArray (Array a)

instance showNonEmptyArray :: Show a => Show (NonEmptyArray a) where
  show (NonEmptyArray xs) = "(NonEmptyArray " <> show xs <> ")"

derive newtype instance eqNonEmptyArray :: Eq a => Eq (NonEmptyArray a)
derive newtype instance eq1NonEmptyArray :: Eq1 NonEmptyArray

derive newtype instance ordNonEmptyArray :: Ord a => Ord (NonEmptyArray a)
derive newtype instance ord1NonEmptyArray :: Ord1 NonEmptyArray

derive newtype instance semigroupNonEmptyArray :: Semigroup (NonEmptyArray a)

derive newtype instance functorNonEmptyArray :: Functor NonEmptyArray
derive newtype instance functorWithIndexNonEmptyArray :: FunctorWithIndex Int NonEmptyArray

derive newtype instance foldableNonEmptyArray :: Foldable NonEmptyArray
derive newtype instance foldableWithIndexNonEmptyArray :: FoldableWithIndex Int NonEmptyArray

instance foldable1NonEmptyArray :: Foldable1 NonEmptyArray where
  foldMap1 = foldMap1Default
  fold1 = fold1Impl (<>)

derive newtype instance unfoldable1NonEmptyArray :: Unfoldable1 NonEmptyArray
derive newtype instance traversableNonEmptyArray :: Traversable NonEmptyArray
derive newtype instance traversableWithIndexNonEmptyArray :: TraversableWithIndex Int NonEmptyArray

instance traversable1NonEmptyArray :: Traversable1 NonEmptyArray where
  traverse1 = traverse1Impl apply map
  sequence1 = sequence1Default

derive newtype instance applyNonEmptyArray :: Apply NonEmptyArray

derive newtype instance applicativeNonEmptyArray :: Applicative NonEmptyArray

derive newtype instance bindNonEmptyArray :: Bind NonEmptyArray

derive newtype instance monadNonEmptyArray :: Monad NonEmptyArray

derive newtype instance altNonEmptyArray :: Alt NonEmptyArray

-- we use FFI here to avoid the unncessary copy created by `tail`
foreign import fold1Impl :: forall a. (a -> a -> a) -> NonEmptyArray a -> a

foreign import traverse1Impl
  :: forall m a b
   . (forall a' b'. (m (a' -> b') -> m a' -> m b'))
  -> (forall a' b'. (a' -> b') -> m a' -> m b')
  -> (a -> m b)
  -> NonEmptyArray a
  -> m (NonEmptyArray b)
