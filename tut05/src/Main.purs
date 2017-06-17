module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.User (getCurrentUser, returnNull)
import Data.Example (getCurrentExample)
import Example1 (openSite)
import Example2 (getPrefs)
import Example3 (streetName)
import Example4 (concatUniq)
import Example5 (wrapExample)
import Example6 (parseDbUrl)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "A collection of Either examples"

  log "Example 1"
  log $ openSite getCurrentUser
  log $ openSite returnNull

  --
  log "Example 2"
  log $ getPrefs getCurrentUser
  -- log $ getPrefs getCurrentUser
  --
  log "Example 3"
  log $ streetName getCurrentUser

  log "Example 4"
  log $ concatUniq "x" "ys"
  log $ concatUniq "y" "y"

  log "Example 5"
  log $ wrapExample getCurrentExample

  log "Example 6"
  log $ parseDbUrl "/postgres:config.com"
  -- log "Game Over"
