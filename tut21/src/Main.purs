module Main where

import Prelude

import Control.Monad.Cont (ContT(..), runContT)
import Effect (Effect)
import Effect.Console (log)
import Control.Monad.Trans.Class (lift)

-- foreign import data TIMEOUT :: Effect

-- type TOF eff = Eff (timeout :: TIMEOUT | eff)

type Milliseconds = Int

foreign import setTimeout
  :: forall eff
   . Milliseconds
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
