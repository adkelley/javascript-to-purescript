-- | Utilities for working with partial functions.
module Partial.Unsafe
  ( unsafePartial
  , unsafePartialBecause
  , unsafeCrashWith
  ) where

import Partial (crashWith)

-- | Discharge a partiality constraint, unsafely.
foreign import unsafePartial :: forall a. (Partial => a) -> a

-- | Discharge a partiality constraint, unsafely. Raises an exception with a
-- | custom error message in the (unexpected) case where `unsafePartial` was
-- | used incorrectly.
foreign import unsafePartialBecause :: forall a. String -> (Partial => a) -> a

-- | A function which crashes with the specified error message.
unsafeCrashWith :: forall a. String -> a
unsafeCrashWith msg = unsafePartial (crashWith msg)
