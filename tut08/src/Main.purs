module Main where

import Prelude hiding (mempty)

import Effect (Effect)
import Effect.Console (log, logShow)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid (mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))


main :: Effect Unit
main = do
  -- semigroups are concatable and associative
  log "Ensure failsafe combination using monoids"
  log "\nAdditive"
  logShow (mempty :: Additive Int) -- (Additive 0)
  logShow $ foldr (<>) mempty [Additive 1, Additive 2, Additive 3]
  -- DRYing the above up
  logShow $ foldr (<>) mempty $ map Additive [1, 2, 3]
  log "\nConj"
  logShow (mempty :: Conj Boolean) -- (Conj true)
  logShow $ foldr (<>) mempty $ Conj <$> [true, true, false]
  logShow $ foldr (<>) mempty $ Conj <$> [true, true, true]
  log "\nFirst"
  logShow (mempty :: First Int) -- First (Nothing)
  logShow $ mempty <> (First (Just [1]))
