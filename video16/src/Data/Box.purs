module Data.Box where

import Prelude

-- const Box = x =>
newtype Box a = Box a
-- Box(x) === Box(x)
derive newtype instance eqBox :: Eq a => Eq (Box a)
-- map: f => Box(f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
-- ap: b2 => b2.map(x)
instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)
-- chain
instance bindBox :: Bind Box where
  bind (Box m) f = f m
-- Box.of(a)
instance applicativeBox :: Applicative Box where
  pure = Box
-- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
