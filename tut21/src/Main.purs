module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

-- foreign import data TIMEOUT :: Effect

-- type TOF eff = Eff (timeout :: TIMEOUT | eff)

type Milliseconds = Int

foreign import setTimeout
  :: Milliseconds
  -> Effect Unit
  -> Effect Unit

type Report =
  { title :: String
  , id    :: Int
  }

reportHeader :: Report -> Report -> String
reportHeader p1 p2 = "Report: " <> p1.title <> " compared to " <> p2.title

main :: Effect Unit
main = do
  log "Write applicative for concurrent actions"
