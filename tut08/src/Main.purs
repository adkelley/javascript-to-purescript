module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid (mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  -- semigroups are concatable and associative
  log "Ensure failsafe combination using monoids"
  -- logShow $ (Additive 1) <> (Additive 2) <> (Additive 3) <> mempty
  logShow $ foldr (<>) mempty $ map Additive [1, 2, 3]
  -- (Conj true) <> (Conj false) <> Conj true <> mempty
  logShow $ foldr (<>) mempty $ map Conj [true, false, true]
  -- logShow $ (Conj true) <> (Conj true) <> (Conj true) <> mempty
  logShow $ foldr (<>) mempty $ map Conj [true, true, true]
  -- logShow First (Just 1) <> First (Just 2) <> First (Just 3) <> mempty
  logShow $ foldr (<>) mempty $ map First [Just 1, Just 2, Just 3]
  -- logShow First Nothing <> First Nothing <> First (Just 3) <> mempty
  logShow $ foldr (<>) mempty $ map First [Nothing, Nothing, Just 3]
