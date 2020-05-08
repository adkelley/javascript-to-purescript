module Test.Main where

import Prelude

import Effect (Effect)
import Test.Data.Enum (testEnum)

main :: Effect Unit
main = testEnum
