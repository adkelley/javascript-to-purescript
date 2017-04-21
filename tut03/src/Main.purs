module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
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
hex (Color n h) = h


result :: ColorName -> String
result name =
  findColor name #
  map hex #
  map (slice 1 0) #
  either (\e -> "No color") toUpper

-- This veraition will make your head spin, but it really shows the power of
-- mapping and composition. 
result' :: ColorName -> String
result' name = either (\e -> "No Color") toUpper $ (slice 1 0) <$> hex <$> (findColor name)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Enforce a null check with composable code branching using Either"
  log $ result "blue"
  log $ result "green"
  log $ result' "yellow"
