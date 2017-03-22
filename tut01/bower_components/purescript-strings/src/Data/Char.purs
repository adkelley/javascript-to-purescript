-- | A type and functions for single characters.
module Data.Char
  ( fromCharCode
  , toCharCode
  , toLower
  , toUpper
  ) where

-- | Returns the numeric Unicode value of the character.
foreign import toCharCode :: Char -> Int

-- | Constructs a character from the given Unicode numeric value.
foreign import fromCharCode :: Int -> Char

-- | Converts a character to lowercase.
foreign import toLower :: Char -> Char

-- | Converts a character to uppercase.
foreign import toUpper :: Char -> Char
