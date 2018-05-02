module Main where

import Prelude

import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Node.FS.Aff (FS)
import Tut12Aff (tut12App, tut12LM, tut12RM)
import Tut13 (app)


main :: ∀ e. Eff (console :: CONSOLE, fs :: FS, exception :: EXCEPTION | e) Unit
main = do
  log "\nTut12 - Task.of, Task.reject examples"
  void $ launchAff tut12App
  log "\nTut12 - Launch/Reject Missle examples"
  void $ launchAff tut12LM
  void $ launchAff tut12RM
  log "\nTut13 - Async Read/Write file example"
  void $ launchAff app
