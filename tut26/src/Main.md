
# Table of Contents



module Main where

import Prelude hiding (apply)

import Data.String.Common (split, joinWith)
import Data.Maybe (Maybe(..))
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Console (log, logShow)

data Iso a b = Iso (a -> b) (b -> a)

inverse :: forall a b. Iso a b -> Iso b a
inverse (Iso f g) = Iso g f

apply :: forall a b. Iso a b -> a -> b
apply (Iso f \_) = f

unapply :: forall a b. Iso a b -> b -> a
unapply apply  inverse

chars :: Iso String (Array String)
chars = Iso (\x -> split (Pattern "") x) (\xs -> joinWith "" xs)

res :: String
res = unapply chars $ apply chars "hello"

main :: Effect Unit
main = do
  log "Hello sailor!"
  logShow res

