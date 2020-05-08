-- | Utilities for working with partial functions.
-- | See the README for more documentation.
module Partial.Unsafe
  ( unsafePartial
  , unsafePartialBecause
  , unsafeCrashWith
  ) where

import Partial (crashWith)

-- | Discharge a partiality constraint, unsafely.
foreign import unsafePartial :: forall a. (Partial => a) -> a

-- | *deprecated:* use `unsafePartial` instead.
unsafePartialBecause :: forall a. String -> (Partial => a) -> a
unsafePartialBecause _ x = unsafePartial x

-- | A function which crashes with the specified error message.
unsafeCrashWith :: forall a. String -> a
unsafeCrashWith msg = unsafePartial (crashWith msg)
