module Bench.Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)

import Bench.Data.List (benchList)

main :: Effect Unit
main = do
  log "List"
  log "===="
  benchList
