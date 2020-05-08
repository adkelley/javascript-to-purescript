-- | This module defines types for some global Javascript functions
-- | and values.
module Global
  ( nan
  , isNaN
  , infinity
  , isFinite
  , readInt
  , readFloat
  , toFixed
  , toExponential
  , toPrecision
  , decodeURI
  , encodeURI
  , decodeURIComponent
  , encodeURIComponent
  ) where

import Prelude
import Data.Function.Uncurried (Fn3, Fn4, runFn3, runFn4)
import Data.Maybe (Maybe(..))

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

foreign import _toFixed :: forall a. Fn4 (String -> a) (String -> a) Int Number a

foreign import _toExponential :: forall a. Fn4 (String -> a) (String -> a) Int Number a

foreign import _toPrecision :: forall a. Fn4 (String -> a) (String -> a) Int Number a

-- | Formats Number as a String with limited number of digits after the dot.
-- | May return `Nothing` when specified number of digits is less than 0 or
-- | greater than 20. See ECMA-262 for more information.
toFixed :: Int -> Number -> Maybe String
toFixed digits n = runFn4 _toFixed (const Nothing) Just digits n

-- | Formats Number as String in exponential notation limiting number of digits
-- | after the decimal dot. May return `Nothing` when specified number of
-- | digits is less than 0 or greater than 20 depending on the implementation.
-- | See ECMA-262 for more information.
toExponential :: Int -> Number -> Maybe String
toExponential digits n = runFn4 _toExponential (const Nothing) Just digits n

-- | Formats Number as String in fixed-point or exponential notation rounded
-- | to specified number of significant digits. May return `Nothing` when
-- | precision is less than 1 or greater than 21 depending on the
-- | implementation. See ECMA-262 for more information.
toPrecision :: Int -> Number -> Maybe String
toPrecision digits n = runFn4 _toPrecision (const Nothing) Just digits n

foreign import _decodeURI :: forall a. Fn3 (String -> a) (String -> a) String a

foreign import _encodeURI :: forall a. Fn3 (String -> a) (String -> a) String a

foreign import _decodeURIComponent :: forall a. Fn3 (String -> a) (String -> a) String a

foreign import _encodeURIComponent :: forall a. Fn3 (String -> a) (String -> a) String a

-- | URI decoding. Returns `Nothing` when given a value with undecodeable
-- | escape sequences.
decodeURI :: String -> Maybe String
decodeURI s = runFn3 _decodeURI (const Nothing) Just s

-- | URI encoding. Returns `Nothing` when given a value with unencodeable
-- | characters.
encodeURI :: String -> Maybe String
encodeURI s = runFn3 _encodeURI (const Nothing) Just s

-- | URI component decoding. Returns `Nothing` when given a value with
-- | undecodeable escape sequences.
decodeURIComponent :: String -> Maybe String
decodeURIComponent s = runFn3 _decodeURIComponent (const Nothing) Just s

-- | URI component encoding. Returns `Nothing` when given a value with
-- | unencodeable characters.
encodeURIComponent :: String -> Maybe String
encodeURIComponent s = runFn3 _encodeURIComponent (const Nothing) Just s
