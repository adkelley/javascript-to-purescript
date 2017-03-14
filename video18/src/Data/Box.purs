module Data.Box where

import Prelude

-- const Box = x =>
newtype Box a = Box a
-- map: f => Box(f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
-- ap: b2 => b2.map(x)
instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)
-- -- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"
