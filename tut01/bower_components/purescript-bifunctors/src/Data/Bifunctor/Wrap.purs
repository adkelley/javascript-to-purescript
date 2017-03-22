module Data.Bifunctor.Wrap where

import Prelude

import Control.Biapplicative (class Biapplicative, bipure)
import Control.Biapply (class Biapply, (<<*>>))

import Data.Bifunctor (class Bifunctor, bimap, rmap)
import Data.Newtype (class Newtype)

-- | Provides a `Functor` over the second argument of a `Bifunctor`.
newtype Wrap p a b = Wrap (p a b)

derive instance newtypeWrap :: Newtype (Wrap p a b) _

derive newtype instance eqWrap :: Eq (p a b) => Eq (Wrap p a b)

derive newtype instance ordWrap :: Ord (p a b) => Ord (Wrap p a b)

instance showWrap :: Show (p a b) => Show (Wrap p a b) where
  show (Wrap x) = "(Wrap " <> show x <> ")"

instance functorWrap :: Bifunctor p => Functor (Wrap p a) where
  map f (Wrap a) = Wrap (rmap f a)

instance bifunctorWrap :: Bifunctor p => Bifunctor (Wrap p) where
  bimap f g (Wrap a) = Wrap (bimap f g a)

instance biapplyWrap :: Biapply p => Biapply (Wrap p) where
  biapply (Wrap fg) (Wrap xy) = Wrap (fg <<*>> xy)

instance biapplicativeWrap :: Biapplicative p => Biapplicative (Wrap p) where
  bipure a b = Wrap (bipure a b)
