module Main where

import Prelude hiding (apply)

import Data.Array (concat, filter, fromFoldable, head, slice)
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Data.String (contains, toUpper)
import Data.String.Common (split, joinWith)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log, logShow)

data Iso a b = Iso (a -> b) (b -> a)

inverse :: forall a b. Iso a b -> Iso b a
inverse (Iso f g) = Iso g f

to :: forall a b. Iso a b -> a -> b
to (Iso f _) = f

from :: forall a b. Iso a b -> b -> a
from = to <<< inverse

chars :: Iso String (Array String)
chars = Iso (split (Pattern "")) (joinWith "")

truncate :: String -> String
truncate xs = from chars $ concat [slice 0 3 $ to chars xs, ["..."]]

single ::  Iso (Either String String) (Array String)
single = Iso (fromFoldable) (first)

first :: Array String -> Either String String
first [] = Left ""
first xs = Right $ fromMaybe "" $ head xs

filterEither :: (String -> Boolean) -> Either String String -> Either String String
filterEither pred m = from single $ filter pred $ to single m

main :: Effect Unit
main = do
  log "Tutorial 26: Isomorphisms"
  log $ from chars $ to chars "hello world"
  log $ truncate "hello world"
  logShow $ toUpper <$> filterEither (\x -> contains (Pattern "h") x) (Right "hello")
  logShow $ toUpper <$> filterEither (\x -> contains (Pattern "h") x) (Right "ello")
