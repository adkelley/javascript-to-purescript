module Data.Bifunctor.Joker where

import Prelude

import Control.Biapplicative (class Biapplicative)
import Control.Biapply (class Biapply)

import Data.Bifunctor (class Bifunctor)
import Data.Newtype (class Newtype)

-- | Make a `Functor` over the second argument of a `Bifunctor`
newtype Joker g a b = Joker (g b)

derive instance newtypeJoker :: Newtype (Joker g a b) _

derive newtype instance eqJoker :: Eq (g b) => Eq (Joker g a b)

derive newtype instance ordJoker :: Ord (g b) => Ord (Joker g a b)

instance showJoker :: Show (g b) => Show (Joker g a b) where
  show (Joker x) = "(Joker " <> show x <> ")"

instance functorJoker :: Functor g => Functor (Joker g a) where
  map g (Joker a) = Joker (map g a)

instance bifunctorJoker :: Functor g => Bifunctor (Joker g) where
  bimap _ g (Joker a) = Joker (map g a)

instance biapplyJoker :: Apply g => Biapply (Joker g) where
  biapply (Joker fg) (Joker xy) = Joker (fg <*> xy)

instance biapplicativeJoker :: Applicative g => Biapplicative (Joker g) where
  bipure _ b = Joker (pure b)
