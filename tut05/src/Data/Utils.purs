module Data.Utils
  ( chain
  , fromNullable
  , fromEmptyString
  , toEither
  , parseValue
  , assignObject2
  ) where

import Prelude

import Effect.Exception (Error, error)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Foreign (Foreign, isNull, isUndefined)
import Simple.JSON (parseJSON)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.List.NonEmpty (head)

foreign import assignObject2Impl :: Fn2 Foreign Foreign Foreign

toEither :: forall a. Boolean -> String -> a -> Either Error a
toEither predicate errorMsg value =
  if predicate
    then Left $ error errorMsg
    else Right value

fromEmptyString :: String -> Either Error String
fromEmptyString value =
  toEither (value == "") "empty string" value

fromNullable :: Foreign -> Either Error Foreign
fromNullable value =
  toEither (isNull value || isUndefined value)
    "null or undefined" value

chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f = either (\e -> Left e) (\a -> f a)

parseValue :: String -> Either Error Foreign
parseValue value =
  case parsed of
    Left nel -> Left $ error $ show $ head nel
    Right x -> Right x
  where parsed = runExcept $ parseJSON value

assignObject2 :: Foreign -> Foreign -> Foreign
assignObject2 = runFn2 assignObject2Impl
