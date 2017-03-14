module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Array (cons, dropWhile, head, null, singleton)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe (fromJust)
import Data.String (toUpper)
import Partial.Unsafe (unsafePartial)

foreign import sliceImpl :: Fn3 Int Int String String

type ColorName = String
type HexValue = String
type Error = String

type Color =
  { name :: ColorName
  , hex  :: HexValue
  }

type Colors = Array Color

findColor :: ColorName -> Colors -> Either Error HexValue
findColor name colors = do
  let found = dropWhile (\c -> c.name /= name) colors
  if (null found)
    then Left "Color was not found"
    else Right $ (\c -> c.hex) $ unsafePartial fromJust $ head found

fold :: Either Error HexValue -> String
fold (Right hex) = hex
fold (Left error ) = error

result :: ColorName -> Colors -> String
result name colors =
  findColor name colors #
  map (runFn3 sliceImpl 1 0) #
  map toUpper #
  fold

newColor :: ColorName -> HexValue -> Color
newColor name hex = { name, hex }

newColors :: Colors
newColors =
  singleton (newColor "red" "#ff4444") #
  cons (newColor "blue" "#44ff44") #
  cons (newColor "yellow" "#fff68f")

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  let colors = newColors
  log $ result "red" colors
  log $ result "green" colors

-- Part 1
-- fold :: Either String Int -> String
-- fold (Right x) = show x
-- fold (Left e ) = e
-- noNegative :: Int -> Either String Int
-- noNegative x | x > 0 = Right x
-- noNegative _ = Left ("Error: negative number")
--
-- result :: Int -> String
-- result x =
--   noNegative x #
--   map(\y -> y + 1) #
--   map(\y -> y / 2) #
--   fold
