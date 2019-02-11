module Main where

import Prelude

import Control.Apply (lift3)
import Data.List (List(..), (:))
import Effect (Effect)
import Effect.Console (log, logShow)

-- pure ~ List.of() in JavaScript
-- f <$> List a == pure f <*> List a
result1 :: List Int
result1 = (\x y → x * y) <$> 1 : 2 : Nil <*> 1 : 2 : Nil

merch1 :: List String
merch1 =
  (\x y z -> x <> "-" <> y <> "-" <> z)
  <$> "teeshirt" : "sweater" : Nil
  <*> "large" : "medium" : "small": Nil
  <*> "black" : "white" : Nil

-- | Use lift3 to rid ourselves of pure & <*>
merch2 :: List String
merch2 = lift3
  (\x y z → x <> "-" <> y <> "-" <> z)
  ("teeshirt" : "sweater" : Nil)
  ("large" : "medium" : "small" : Nil)
  ("black" : "white" : Nil)

-- | Use applicative do notation introduced in 0.12.0
merch3 :: List String
merch3 = ado
  x <- "teeshirt" : "sweater" : Nil
  y <- "large" : "medium" : "small" : Nil
  z <- "black" : "white" : Nil
  in (x <> "-" <> y <> "-" <> z)

main :: Effect Unit
main = do
  log "List comprehensions with Applicative Functors"
  log "\nConstructing a list using pure & <*>"
  logShow $ result1
  log "\nMerchandise list using pure & <*>"
  logShow $ merch1
  log "\nMerchandise list using lift from Control.Apply"
  logShow $ merch2
  log "\nMerchandise list using applicative do notation"
  logShow $ merch3
