module Data.Bifunctor.Clown where

import Prelude

import Control.Biapplicative (class Biapplicative)
import Control.Biapply (class Biapply)

import Data.Bifunctor (class Bifunctor)
import Data.Newtype (class Newtype)

-- | Make a `Functor` over the first argument of a `Bifunctor`
newtype Clown f a b = Clown (f a)

derive instance newtypeClown :: Newtype (Clown f a b) _

derive newtype instance eqClown :: Eq (f a) => Eq (Clown f a b)

derive newtype instance ordClown :: Ord (f a) => Ord (Clown f a b)

instance showClown :: Show (f a) => Show (Clown f a b) where
  show (Clown x) = "(Clown " <> show x <> ")"

instance functorClown :: Functor (Clown f a) where
  map _ (Clown a) = Clown a

instance bifunctorClown :: Functor f => Bifunctor (Clown f) where
  bimap f _ (Clown a) = Clown (map f a)

instance biapplyClown :: Apply f => Biapply (Clown f) where
  biapply (Clown fg) (Clown xy) = Clown (fg <*> xy)

instance biapplicativeClown :: Applicative f => Biapplicative (Clown f) where
  bipure a _ = Clown (pure a)
