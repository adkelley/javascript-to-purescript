module Main where

import Prelude

import Control.Monad.Cont (ContT(..), runContT)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Trans.Class (lift)

foreign import data TIMEOUT :: Effect

type TOF eff = Eff (timeout :: TIMEOUT | eff)

type Milliseconds = Int

foreign import setTimeout
  :: forall eff
   . Milliseconds
  -> (TOF eff) Unit
  -> (TOF eff) Unit

type Report =
  { title :: String
  , id    :: Int
  }

reportHeader :: Report -> Report -> String
reportHeader p1 p2 = "Report: " <> p1.title <> " compared to " <> p2.title

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Write applicative for concurrent actions"
