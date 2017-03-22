module Data.Field
  ( class Field
  , module Data.CommutativeRing
  , module Data.EuclideanRing
  , module Data.Ring
  , module Data.Semiring
  ) where

import Data.CommutativeRing (class CommutativeRing)
import Data.EuclideanRing (class EuclideanRing, degree, div, mod, (/), gcd, lcm)
import Data.Ring (class Ring, negate, sub)
import Data.Semiring (class Semiring, add, mul, one, zero, (*), (+))
import Data.Unit (Unit)

-- | The `Field` class is for types that are commutative fields.
-- |
-- | Instances must satisfy the following law in addition to the
-- | `EuclideanRing` laws:
-- |
-- | - Non-zero multiplicative inverse: ``a `mod` b = zero`` for all `a` and `b`
-- |
-- | The `Unit` instance is provided for backwards compatibility, but it is
-- | not law-abiding, because `Unit` does not obey the `EuclideanRing` laws.
-- | This instance will be removed in a future release.
class EuclideanRing a <= Field a

instance fieldNumber :: Field Number
instance fieldUnit :: Field Unit
