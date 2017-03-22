-- | This module defines types for some global Javascript functions
-- | and values.
module Global where

-- | Not a number (NaN)
foreign import nan :: Number

-- | Test whether a number is NaN
foreign import isNaN :: Number -> Boolean

-- | Positive infinity
foreign import infinity :: Number

-- | Test whether a number is finite
foreign import isFinite :: Number -> Boolean

-- | Parse an integer from a `String` in the specified base
foreign import readInt :: Int -> String -> Number

-- | Parse a floating point value from a `String`
foreign import readFloat :: String -> Number

-- | uri decoding
foreign import decodeURI :: String -> String

-- | uri encoding
foreign import encodeURI :: String -> String

-- | uri component decoding
foreign import decodeURIComponent :: String -> String

-- | uri component encoding
foreign import encodeURIComponent :: String -> String
