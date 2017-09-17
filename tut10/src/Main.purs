module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Foldable (foldMap, foldr)
import Data.Group (ginverse)
import Data.Maybe.First (First(..))
import Data.Monoid (mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Tuple (Tuple(..), snd)

type Sum = Additive Int
type A = Array

mapSum :: (Int -> Sum) -> A Int -> A Sum
mapSum fn = map fn

foldSum :: (Sum -> Sum -> Sum) -> Sum -> A (Sum) -> Sum
foldSum fn neutral = foldr fn neutral

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Unbox types with foldMap"
  logShow $ foldMap id [(Additive 1), (Additive 2), (Additive 3)]
  logShow $ foldMap Additive [1, 2, 3]
  logShow $ foldMap (Additive <<< snd) [Tuple "brian" 1, Tuple "sarah" 2]
  logShow $ (Additive 3) <> ginverse (Additive 3)
  logShow $ mempty :: First Int
  logShow $ foldSum (<>) (Additive 0) $ mapSum Additive [1, 2, 3]
