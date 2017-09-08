
module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Foldable (foldMap)
import Data.Monoid.Additive (Additive(..))
import Data.Tuple (Tuple(..), snd)
import Data.Group (ginverse)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Unbox types with foldMap"
  logShow $ foldMap id [(Additive 1), (Additive 2), (Additive 3)]
  logShow $ foldMap Additive [1, 2, 3]
  logShow $ foldMap (Additive <<< snd) [Tuple "brian" 1, Tuple "sarah" 2]
  logShow $ (Additive 3) <> ginverse (Additive 3)
