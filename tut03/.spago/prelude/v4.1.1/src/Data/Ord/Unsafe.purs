module Data.Ord.Unsafe (unsafeCompare) where

import Prim.TypeError (class Warn, Text)
import Data.Ordering (Ordering(..))

unsafeCompare
    :: forall a.
       Warn (Text "'unsafeCompare' is deprecated.")
    => a -> a -> Ordering
unsafeCompare = unsafeCompareImpl LT EQ GT

foreign import unsafeCompareImpl
  :: forall a
   . Ordering
  -> Ordering
  -> Ordering
  -> a
  -> a
  -> Ordering
