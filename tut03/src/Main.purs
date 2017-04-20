module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Either (Either(..), either)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.List (List, dropWhile, singleton, (:))
import Data.List.NonEmpty (NonEmptyList(..), fromList)
import Data.Maybe (Maybe(..))
import Data.NonEmpty ((:|))
import Data.String (toUpper)

foreign import sliceImpl :: Fn3 Int Int String String

slice :: Int -> Int -> String -> String
slice begin end string =
  runFn3 sliceImpl begin end string

type ColorName = String
type HexValue = String
type Error = String

data Color = Color ColorName HexValue

type Colors = List Color

masterColors :: Colors
masterColors = (Color "red" "#ff4444")  : 
               (Color "blue" "#44ff44") :
               singleton (Color "yellow" "#fff68f")


hex :: Maybe (NonEmptyList Color) -> Either Error HexValue
hex (Just (NonEmptyList ((Color _ h) :| _))) = Right h
hex _ = Left "Color not found"

findColor :: ColorName -> Either Error HexValue
findColor colorName =
  hex <$> fromList $ dropWhile (\(Color n _) -> n /= colorName) masterColors

result :: ColorName -> String
result name =
  findColor name #
  map (slice 1 0) #
  either (\e -> "Error: " <> e) (\c -> "Hex Value: " <> (toUpper c))

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Enforce a null check with composable code branching using Either"
  log $ result "blue"
  log $ result "green"
