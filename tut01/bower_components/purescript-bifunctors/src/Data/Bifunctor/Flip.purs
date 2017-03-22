module Data.Bifunctor.Flip where

import Prelude

import Control.Biapplicative (class Biapplicative, bipure)
import Control.Biapply (class Biapply, (<<*>>))

import Data.Bifunctor (class Bifunctor, bimap, lmap)
import Data.Newtype (class Newtype)

-- | Flips the order of the type arguments of a `Bifunctor`.
newtype Flip p a b = Flip (p b a)

derive instance newtypeFlip :: Newtype (Flip p a b) _

derive newtype instance eqFlip :: Eq (p b a) => Eq (Flip p a b)

derive newtype instance ordFlip :: Ord (p b a) => Ord (Flip p a b)

instance showFlip :: Show (p a b) => Show (Flip p b a) where
  show (Flip x) = "(Flip " <> show x <> ")"

instance functorFlip :: Bifunctor p => Functor (Flip p a) where
  map f (Flip a) = Flip (lmap f a)

instance bifunctorFlip :: Bifunctor p => Bifunctor (Flip p) where
  bimap f g (Flip a) = Flip (bimap g f a)

instance biapplyFlip :: Biapply p => Biapply (Flip p) where
  biapply (Flip fg) (Flip xy) = Flip (fg <<*>> xy)

instance biapplicativeFlip :: Biapplicative p => Biapplicative (Flip p) where
  bipure a b = Flip (bipure b a)
