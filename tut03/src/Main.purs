module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Array (dropWhile, null)
import Data.Array.Partial (head)
import Data.Either (Either(..), either)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.String (toUpper)
import Partial.Unsafe (unsafePartial)

-- Had we manually curried our arguments in our JavaScript code:
--   foreign import sliceImpl :: Int -> Int -> String -> String
-- Instead we'll take advantage of Fn3:
foreign import sliceImpl :: Fn3 Int Int String String

slice :: Int -> Int -> String -> String
slice begin end string =
  -- Had we manually curried our arguments in our JavaScript code:
  --   sliceImpl begin end string
  -- Instead we'll take advantage of runFn3:
  runFn3 sliceImpl begin end string

type ColorName = String
type HexValue = String
type Error = String

data Color = Color ColorName HexValue

type Colors = Array Color

fromNullable :: Colors -> Either Error HexValue
fromNullable colors =
  if (null colors)
    then Left "Color was not found"
    else Right $ (\(Color _ h) -> h) $ unsafePartial head colors

masterColors :: Colors
masterColors = [ (Color "red" "#ff4444")
               , (Color "blue" "#44ff44")
               , (Color "yellow" "#fff68f")
               ]

findColor :: ColorName -> Either Error HexValue
findColor colorName =
  fromNullable $ dropWhile (\(Color n _) -> n /= colorName) masterColors

result :: ColorName -> String
result name =
  findColor name #
  map (slice 1 0) #
  either (\e -> "Error: " <> e) (\c -> "Hex Value: " <> (toUpper c))

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Enforce a null check with composable code branching using Either"
  log $ result "red"
  log $ result "green"
