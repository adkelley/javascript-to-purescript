module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Example (getCurrentExample)
import Data.Foreign (unsafeFromForeign)
import Data.User (getCurrentUser, returnNull)
import Example1 (openSite)
import Example2 (getPrefs)
import Example3 (streetName)
import Example4 (concatUniq)
import Example5 (wrapExample, wrapExample_)
import Example6 (parseDbUrl, parseDbUrl_)
import Node.FS (FS)

defaultConfig :: String
defaultConfig = "{ \"url\": \"postgres:\\/\\/username:password@localhost/myjavascriptdb\"}\n"

main :: forall e. Eff (fs :: FS, exception :: EXCEPTION, console :: CONSOLE | e) Unit
main = do
  log "A collection of Either examples"

  log "Example 1"
  log $ openSite getCurrentUser
  log $ openSite returnNull

  log "Example 2"
  log $ getPrefs getCurrentUser

  log "Example 3"
  log $ streetName getCurrentUser

  log "Example 4"
  log $ concatUniq "x" "ys"
  log $ concatUniq "y" "y"

  log "Example 5"
  log "using where keyword in wrapExample"
  example <- wrapExample getCurrentExample
  log $ unsafeFromForeign example :: String
  log "using let keyword in wrapExample_"
  example_ <- wrapExample_ getCurrentExample
  log $ unsafeFromForeign example_ :: String
  -- or this way
  -- (wrapExample_ getCurrentExample) >>=
  -- (\example_ -> log $ unsafeFromForeign example_ :: String)

  log "Example 6"
  log "Using chain to help parse the database URL"
  logShow $ parseDbUrl_ defaultConfig
  log "Using bind to help parse the database URL"
  logShow $ parseDbUrl defaultConfig

  log "Game Over"
