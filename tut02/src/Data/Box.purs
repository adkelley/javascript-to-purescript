module Data.Box
  ( Box(..)
  ) where

import Prelude
import Control.Comonad (class Comonad, class Extend)

-- const Box = x =>
newtype Box a = Box a
-- map: f => Box(f(x))
instance functorBox :: Functor Box where
 map f (Box x) = Box (f x)
-- -- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
-- fold: f => f(x)
-- Box(Number) is not a monoid, and therefore unfoldable
-- so we run a function (fold) that pattern matches on x to
-- compute f x
instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)
instance applicativeBox :: Applicative Box where
  pure = Box

instance bindBox :: Bind Box where
  bind (Box m) f = f m

instance monadBox :: Monad Box
instance extendBox :: Extend Box where
  extend f m = Box (f m)
instance comonadBox :: Comonad Box where
  extract (Box x) = x
