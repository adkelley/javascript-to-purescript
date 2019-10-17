module Main where

import Prelude hiding (apply)

import Data.Array (filter, fromFoldable, head, slice, union)
import Data.Maybe (Maybe(..))
import Data.String (contains, toUpper)
import Data.String.Common (split, joinWith)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log, logShow)

data Iso a b = Iso (a -> b) (b -> a)

inverse :: forall a b. Iso a b -> Iso b a
inverse (Iso f g) = Iso g f

apply :: forall a b. Iso a b -> a -> b
apply (Iso f _) = f

unapply :: forall a b. Iso a b -> b -> a
unapply = apply <<< inverse

chars :: Iso String (Array String)
chars = Iso (\x -> split (Pattern "") x) (\x -> joinWith "" x)

truncate :: String -> String
truncate = unapply chars <<< \x -> union (slice 0 3 $ apply chars x) ["..."]

single ::  forall a. Iso (Maybe a) (Array a)
single = Iso (\xs -> fromFoldable xs)
             (\xs -> head xs)

filterMaybe :: forall a. (a -> Boolean) -> Maybe a -> Maybe a
filterMaybe pred m = unapply single $ filter pred $ apply single m

main :: Effect Unit
main = do
  log "Hello sailor!"
  logShow $ unapply chars $ apply chars "hello world"
  logShow $ truncate "hello world"
  logShow $ toUpper <$> filterMaybe (\x -> contains (Pattern "h") x) (Just "hello")
