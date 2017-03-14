module Data.String.Regex.Unsafe
( unsafeRegex
) where

import Data.Either (fromRight)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (RegexFlags)

import Partial.Unsafe (unsafePartial)

-- | Constructs a `Regex` from a pattern string and flags. Fails with
-- | an exception if the pattern contains a syntax error.
unsafeRegex :: String -> RegexFlags -> Regex
unsafeRegex s f = unsafePartial fromRight (regex s f)
