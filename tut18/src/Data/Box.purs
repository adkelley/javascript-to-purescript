module Data.Box where

import Prelude
import Data.Eq (class Eq1)

-- | The comments reflect the JavaScript
-- | from Brian's box.js module

-- const Box = x =>
newtype Box a = Box a

-- map: f => Box(f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)

-- ap: b2 => b2.map(x)
instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)

-- pure ~ of: Box
instance applicativeBox ∷ Applicative Box where
  pure = Box

-- -- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"

-- | The `Eq` instance allows `Box` values to be checked
-- | for equality whenever theres is an `Eq` instance for
-- | for the type `Box` contains
derive instance eqBox ∷ Eq a ⇒ Eq (Box a)

instance eq1Box ∷ Eq1 Box where eq1 = eq
