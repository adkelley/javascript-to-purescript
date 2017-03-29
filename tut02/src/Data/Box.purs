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

-- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"

instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)

-- module.exports = { Box, of: Box }
instance applicativeBox :: Applicative Box where
  pure = Box

-- chain: f => f(x)
instance bindBox :: Bind Box where
  bind (Box m) f = f m
instance monadBox :: Monad Box
instance extendBox :: Extend Box where
  extend f m = Box (f m)

-- My approach to addressing fold: f => f(x), but instead
-- don't apply a function f, just take x out of the Box
instance comonadBox :: Comonad Box where
  extract (Box x) = x
