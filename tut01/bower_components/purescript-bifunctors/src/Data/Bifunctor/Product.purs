module Data.Bifunctor.Product where

import Prelude

import Control.Biapplicative (class Biapplicative, bipure)
import Control.Biapply (class Biapply, biapply)

import Data.Bifunctor (class Bifunctor, bimap)

-- | The product of two `Bifunctor`s.
data Product f g a b = Product (f a b) (g a b)

derive instance eqProduct :: (Eq (f a b), Eq (g a b)) => Eq (Product f g a b)

derive instance ordProduct :: (Ord (f a b), Ord (g a b)) => Ord (Product f g a b)

instance showProduct :: (Show (f a b), Show (g a b)) => Show (Product f g a b) where
  show (Product x y) = "(Product " <> show x <> " " <> show y <> ")"

instance bifunctorProduct :: (Bifunctor f, Bifunctor g) => Bifunctor (Product f g) where
  bimap f g (Product x y) = Product (bimap f g x) (bimap f g y)

instance biapplyProduct :: (Biapply f, Biapply g) => Biapply (Product f g) where
  biapply (Product w x) (Product y z) = Product (biapply w y) (biapply x z)

instance biapplicativeProduct :: (Biapplicative f, Biapplicative g) => Biapplicative (Product f g) where
  bipure a b = Product (bipure a b) (bipure a b)
