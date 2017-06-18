module Data.Utils
  ( chain
  , fromNullable
  , fromEmptyString
  , parseValue
  , assignObject2
  ) where

import Prelude

import Control.Monad.Eff.Exception (Error, error)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Foreign (Foreign, isNull, isUndefined)
import Data.Foreign.JSON (parseJSON)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.List.NonEmpty (head)

foreign import assignObject2Impl :: Fn2 Foreign Foreign Foreign

fromEmptyString :: String -> Either Error String
fromEmptyString value =
  if (value == "")
    then Left $ error "empty string"
    else Right value

fromNullable :: Foreign -> Either Error Foreign
fromNullable value =
  if (isNull value || isUndefined value)
   then Left $ error "value is null or undefined"
   else Right value

chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f  = either (\e -> Left e) (\x -> (f x))

parseValue :: String -> Either Error Foreign
parseValue value =
  case parsed of
    Left nel -> Left $ error $ show $ head nel
    Right x -> Right x
  where parsed = runExcept $ parseJSON value

assignObject2 :: Foreign -> Foreign -> Foreign
assignObject2 = runFn2 assignObject2Impl
