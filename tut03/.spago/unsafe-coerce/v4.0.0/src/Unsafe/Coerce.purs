
module Unsafe.Coerce
  ( unsafeCoerce
  ) where

-- | A _highly unsafe_ function, which can be used to persuade the type system that
-- | any type is the same as any other type. When using this function, it is your
-- | (that is, the caller's) responsibility to ensure that the underlying
-- | representation for both types is the same.
-- |
-- | One application for this function is to avoid doing work that you know is a
-- | no-op because of newtypes. For example, if you have an `Array (Conj a)` and you
-- | want an `Array (Disj a)`, you could do `Data.Array.map (runConj >>> Disj)`, but
-- | this performs an unnecessary traversal. `unsafeCoerce` accomplishes the same
-- | for free.
-- |
-- | It is highly recommended to define specializations of this function rather than
-- | using it as-is. For example:
-- |
-- | ```purescript
-- | mapConjToDisj :: forall a. Array (Conj a) -> Array (Disj a)
-- | mapConjToDisj = unsafeCoerce
-- | ```
-- |
-- | This way, you won't have any nasty surprises due to the inferred type being
-- | different to what you expected.
foreign import unsafeCoerce :: forall a b. a -> b
