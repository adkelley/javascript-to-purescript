module Data.EuclideanRing
  ( class EuclideanRing, degree, div, mod, (/)
  , gcd
  , lcm
  , module Data.CommutativeRing
  , module Data.Ring
  , module Data.Semiring
  ) where

import Data.BooleanAlgebra ((||))
import Data.CommutativeRing (class CommutativeRing)
import Data.Eq (class Eq, (==))
import Data.Ring (class Ring, sub, (-))
import Data.Semiring (class Semiring, add, mul, one, zero, (*), (+))
import Data.Unit (Unit, unit)

-- | The `EuclideanRing` class is for commutative rings that support division.
-- | The mathematical structure this class is based on is sometimes also called
-- | a *Euclidean domain*.
-- |
-- | Instances must satisfy the following laws in addition to the `Ring`
-- | laws:
-- |
-- | - Integral domain: `one /= zero`, and if `a` and `b` are both nonzero then
-- |   so is their product `a * b`
-- | - Euclidean function `degree`:
-- |   - Nonnegativity: For all nonzero `a`, `degree a >= 0`
-- |   - Quotient/remainder: For all `a` and `b`, where `b` is nonzero,
-- |     let `q = a / b` and ``r = a `mod` b``; then `a = q*b + r`, and also
-- |     either `r = zero` or `degree r < degree b`
-- | - Submultiplicative euclidean function:
-- |   - For all nonzero `a` and `b`, `degree a <= degree (a * b)`
-- |
-- | The behaviour of division by `zero` is unconstrained by these laws,
-- | meaning that individual instances are free to choose how to behave in this
-- | case. Similarly, there are no restrictions on what the result of
-- | `degree zero` is; it doesn't make sense to ask for `degree zero` in the
-- | same way that it doesn't make sense to divide by `zero`, so again,
-- | individual instances may choose how to handle this case.
-- |
-- | For any `EuclideanRing` which is also a `Field`, one valid choice
-- | for `degree` is simply `const 1`. In fact, unless there's a specific
-- | reason not to, `Field` types should normally use this definition of
-- | `degree`.
-- |
-- | The `Unit` instance is provided for backwards compatibility, but it is
-- | not law-abiding, because `Unit` fails to form an integral domain. This
-- | instance will be removed in a future release.
class CommutativeRing a <= EuclideanRing a where
  degree :: a -> Int
  div :: a -> a -> a
  mod :: a -> a -> a

infixl 7 div as /

instance euclideanRingInt :: EuclideanRing Int where
  degree = intDegree
  div = intDiv
  mod = intMod

instance euclideanRingNumber :: EuclideanRing Number where
  degree _ = 1
  div = numDiv
  mod _ _ = 0.0

instance euclideanRingUnit :: EuclideanRing Unit where
  degree _ = 1
  div _ _ = unit
  mod _ _ = unit

foreign import intDegree :: Int -> Int
foreign import intDiv :: Int -> Int -> Int
foreign import intMod :: Int -> Int -> Int

foreign import numDiv :: Number -> Number -> Number

-- | The *greatest common divisor* of two values.
gcd :: forall a. (Eq a, EuclideanRing a) => a -> a -> a
gcd a b =
  if b == zero
    then a
    else gcd b (a `mod` b)

-- | The *least common multiple* of two values.
lcm :: forall a. (Eq a, EuclideanRing a) => a -> a -> a
lcm a b =
  if a == zero || b == zero
    then zero
    else a * b / gcd a b
