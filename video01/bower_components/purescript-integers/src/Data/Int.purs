module Data.Int
  ( fromNumber
  , ceil
  , floor
  , round
  , toNumber
  , fromString
  , Radix
  , radix
  , binary
  , octal
  , decimal
  , hexadecimal
  , base36
  , fromStringAs
  , toStringAs
  , even
  , odd
  , pow
  ) where

import Prelude

import Data.Int.Bits ((.&.))
import Data.Maybe (Maybe(..), fromMaybe)
import Global (infinity)

import Math as Math

-- | Creates an `Int` from a `Number` value. The number must already be an
-- | integer and fall within the valid range of values for the `Int` type
-- | otherwise `Nothing` is returned.
fromNumber :: Number -> Maybe Int
fromNumber = fromNumberImpl Just Nothing

foreign import fromNumberImpl
  :: (forall a. a -> Maybe a)
  -> (forall a. Maybe a)
  -> Number
  -> Maybe Int

-- | Convert a `Number` to an `Int`, by taking the closest integer equal to or
-- | less than the argument. Values outside the `Int` range are clamped, `NaN`
-- | and `Infinity` values return 0.
floor :: Number -> Int
floor = unsafeClamp <<< Math.floor

-- | Convert a `Number` to an `Int`, by taking the closest integer equal to or
-- | greater than the argument. Values outside the `Int` range are clamped,
-- | `NaN` and `Infinity` values return 0.
ceil :: Number -> Int
ceil = unsafeClamp <<< Math.ceil

-- | Convert a `Number` to an `Int`, by taking the nearest integer to the
-- | argument. Values outside the `Int` range are clamped, `NaN` and `Infinity`
-- | values return 0.
round :: Number -> Int
round = unsafeClamp <<< Math.round

-- | Convert an integral `Number` to an `Int`, by clamping to the `Int` range.
-- | This function will return 0 if the input is `NaN` or an `Infinity`.
unsafeClamp :: Number -> Int
unsafeClamp x
  | x == infinity = 0
  | x == -infinity = 0
  | x >= toNumber top = top
  | x <= toNumber bottom = bottom
  | otherwise = fromMaybe 0 (fromNumber x)

-- | Converts an `Int` value back into a `Number`. Any `Int` is a valid `Number`
-- | so there is no loss of precision with this function.
foreign import toNumber :: Int -> Number

-- | Reads an `Int` from a `String` value. The number must parse as an integer
-- | and fall within the valid range of values for the `Int` type, otherwise
-- | `Nothing` is returned.
fromString :: String -> Maybe Int
fromString = fromStringAs (Radix 10)

-- | Returns whether an `Int` is an even number.
-- |
-- | ``` purescript
-- | even 0 == true
-- | even 1 == false
-- | ```
even :: Int -> Boolean
even x = x .&. 1 == 0

-- | The negation of `even`.
-- |
-- | ``` purescript
-- | odd 0 == false
-- | odd 1 == false
-- | ```
odd :: Int -> Boolean
odd x = x .&. 1 /= 0

-- | The number of unique digits (including zero) used to represent integers in
-- | a specific base.
newtype Radix = Radix Int

-- | The base-2 system.
binary :: Radix
binary = Radix 2

-- | The base-8 system.
octal :: Radix
octal = Radix 8

-- | The base-10 system.
decimal :: Radix
decimal = Radix 10

-- | The base-16 system.
hexadecimal :: Radix
hexadecimal = Radix 16

-- | The base-36 system.
base36 :: Radix
base36 = Radix 36

-- | Create a `Radix` from a number between 2 and 36.
radix :: Int -> Maybe Radix
radix n | n >= 2 && n <= 36 = Just (Radix n)
        | otherwise         = Nothing

-- | Like `fromString`, but the integer can be specified in a different base.
-- |
-- | Example:
-- | ``` purs
-- | fromStringAs binary      "100" == Just 4
-- | fromStringAs hexadecimal "ff"  == Just 255
-- | ```
fromStringAs :: Radix -> String -> Maybe Int
fromStringAs = fromStringAsImpl Just Nothing

-- | Raise an Int to the power of another Int.
foreign import pow :: Int -> Int -> Int

foreign import fromStringAsImpl
  :: (forall a. a -> Maybe a)
  -> (forall a. Maybe a)
  -> Radix
  -> String
  -> Maybe Int

foreign import toStringAs :: Radix -> Int -> String
