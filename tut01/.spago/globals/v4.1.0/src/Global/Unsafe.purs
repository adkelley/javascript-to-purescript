module Global.Unsafe where

-- | Uses the global JSON object to turn anything into a string. Careful! Trying
-- | to serialize functions returns undefined
foreign import unsafeStringify :: forall a. a -> String

-- | Formats Number as a String with limited number of digits after the dot.
-- |
-- | May throw RangeError if the number of digits is not within the allowed range
-- | (standard precision range is 0 to 20, but implementations may change it)
foreign import unsafeToFixed :: Int -> Number -> String

-- | Formats Number as String in exponential notation limiting number of digits
-- | after the decimal dot.
-- |
-- | May throw RangeError if the number of digits is not within the allowed range
-- | (standard precision range is 0 to 20, but implementations may change it)
foreign import unsafeToExponential :: Int -> Number -> String

-- | Formats Number as String in fixed-point or exponential notation rounded
-- | to specified number of significant digits.
-- |
-- | May throw RangeError if the number of digits is not within the allowed range
-- | (standard precision range is 0 to 100, but implementations may change it)
foreign import unsafeToPrecision :: Int -> Number -> String

-- | URI decoding. May throw a `URIError` if given a value with undecodeable
-- | escape sequences.
foreign import unsafeDecodeURI :: String -> String

-- | URI encoding. May throw a `URIError` if given a value with unencodeable
-- | characters.
foreign import unsafeEncodeURI :: String -> String

-- | URI component decoding. May throw a `URIError` if given a value with
-- | undecodeable escape sequences.
foreign import unsafeDecodeURIComponent :: String -> String

-- | URI component encoding. May throw a `URIError` if given a value with
-- | unencodeable characters.
foreign import unsafeEncodeURIComponent :: String -> String
