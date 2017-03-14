module Data.Void (Void, absurd) where

import Data.Show (class Show)

-- | An uninhabited data type.
-- |
-- | `Void` is useful to eliminate the possibility of a value being created.
-- | For example, a value of type `Either Void Boolean` can never have
-- | a Left value created in PureScript.
newtype Void = Void Void

instance showVoid :: Show Void where
  show = absurd

absurd :: forall a. Void -> a
absurd a = spin a
  where
  spin (Void b) = spin b
