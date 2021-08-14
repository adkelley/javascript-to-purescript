module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Either (Either(..), either)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.List (List(..), dropWhile, head, null, (:))
import Data.Maybe (fromJust)
import Data.String (toUpper)
import Partial.Unsafe (unsafePartial)

foreign import sliceImpl :: Fn3 Int Int String String

slice :: Int -> Int -> String -> String
slice begin end string =
  runFn3 sliceImpl begin end string

type ColorName = String
type HexValue = String
type Error = Unit

data Color = Color ColorName HexValue
type Colors = List Color

masterColors :: Colors
masterColors = (Color "red" "#ff4444")  :
               (Color "blue" "#44ff44") :
               (Color "yellow" "#fff68f") : Nil


fromList :: forall a. List a -> Either Unit a
fromList xs =
  if (null xs)
    then Left unit
    else Right $ unsafePartial fromJust $ head xs


findColor :: ColorName -> Either Error Color
findColor colorName =
  fromList $ dropWhile (\(Color n _) -> n /= colorName) masterColors


hex :: Color -> HexValue
hex (Color _ h) = h


result :: ColorName -> String
result name =
  findColor name #
  map hex #
  map (slice 1 0) #
  either (\_ -> "No color") toUpper

-- Bonus: This variation will make your head spin. It really shows the power of
-- mapping and composition. All in one expression!  Thanks to @goodacre.liam on
-- on the FP #purescript forum on Slack for this example
result' :: ColorName -> String
result' = either (const "No Color") toUpper <<< map (slice 1 0 <<< hex) <<< findColor


main :: Effect Unit
main = do
  log "Enforce a null check with composable code branching using Either"
  log $ result "blue"
  log $ result "green"
  log $ result' "yellow"
