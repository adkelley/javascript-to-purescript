module Data.Monoid.Endo where

import Prelude

import Data.Functor.Invariant (class Invariant)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype)

-- | Monoid of endomorphisms under composition.
-- |
-- | Composes of functions of type `a -> a`:
-- | ``` purescript
-- | Endo f <> Endo g == Endo (f <<< g)
-- | mempty :: Endo _ == Endo id
-- | ```
newtype Endo a = Endo (a -> a)

derive instance newtypeEndo :: Newtype (Endo a) _

instance invariantEndo :: Invariant Endo where
  imap ab ba (Endo f) = Endo (ab <<< f <<< ba)

instance semigroupEndo :: Semigroup (Endo a) where
  append (Endo f) (Endo g) = Endo (f <<< g)

instance monoidEndo :: Monoid (Endo a) where
  mempty = Endo id
