module Main where

import Prelude hiding (apply)

import Data.Array (concat, filter, fromFoldable, head, slice, union)
import Data.Maybe (Maybe(..))
import Data.String (contains, toUpper)
import Data.String.Common (split, joinWith)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log, logShow)

-- This is called a partial isomorphism because (a -> b) and (b -> a)
-- are partial functions.
data Iso a b = Iso (a -> b) (b -> a)

inverse :: forall a b. Iso a b -> Iso b a
inverse (Iso f g) = Iso g f

apply :: forall a b. Iso a b -> a -> b
apply (Iso f _) = f

unapply :: forall a b. Iso a b -> b -> a
unapply = apply <<< inverse

chars :: Iso String (Array String)
chars = Iso (split (Pattern "")) (joinWith "")

truncate :: String -> String
truncate xs = unapply chars $ concat [(slice 0 3 $ apply chars xs), ["..."]]

single ::  forall a. Iso (Maybe a) (Array a)
single = Iso (fromFoldable) (head)

filterMaybe :: forall a. (a -> Boolean) -> Maybe a -> Maybe a
filterMaybe pred m = unapply single $ filter pred $ apply single m

main :: Effect Unit
main = do
  log "Hello sailor!"
  logShow $ unapply chars $ apply chars "hello world"
  logShow $ truncate "hello world"
  logShow $ toUpper <$> filterMaybe (\x -> contains (Pattern "h") x) (Just "hello")
