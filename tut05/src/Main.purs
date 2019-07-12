module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Data.Example (getCurrentExample)
import Foreign (unsafeFromForeign)
import Data.User (getCurrentUser, returnNull)
import Example1 (openSite)
import Example2 (getPrefs)
import Example3 (streetName)
import Example4 (concatUniq)
import Example5 (wrapExample, wrapExample_)
import Example6 (parseDbUrl, parseDbUrl_)
import Partial.Unsafe (unsafePartial)

defaultConfig :: String
defaultConfig = "{ \"url\": \"postgres:\\/\\/username:password@localhost/myjavascriptdb\"}\n"

main :: Effect Unit
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
  log $ concatUniq 'x' "ys"
  log $ concatUniq 'y' "y"

  log "Example 5"
  log "using where keyword in wrapExample"
  example <- wrapExample getCurrentExample
  log (unsafeFromForeign example :: String)
  log "using let keyword in wrapExample_"
  example_ <- wrapExample_ getCurrentExample
  log (unsafeFromForeign example_ :: String)
  -- or this way
  -- (wrapExample_ getCurrentExample) >>=
  -- (\example_ -> log $ unsafeFromForeign example_ :: String)

  log "Example 6"
  log "Using chain to help parse the database URL"
  logShow $ unsafePartial $ parseDbUrl_ defaultConfig
  log "Using bind to help parse the database URL"
  logShow $ unsafePartial $ parseDbUrl defaultConfig

  log "Game Over"
