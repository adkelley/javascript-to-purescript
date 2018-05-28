module Main where

import Prelude

import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Aff.Console (log) as AC
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Task (fork)
import Node.FS.Aff (FS)
import Tut12Aff (tut12Res, tut12Rej, tut12Chain, tut12LM, tut12RM)
import Tut13 (app)


main :: ∀ e. Eff (console :: CONSOLE, fs :: FS, exception :: EXCEPTION | e) Unit
main = do
  log "\nTut12 - Task.of example"
  void $ launchAff tut12Res
  log "\nTut12 - Task.rejected example"
  void $ launchAff tut12Rej
  log "\nTut12 - Chaining tasks example"
  void $ launchAff tut12Chain
  log "\nTut12 - Launch/Reject Missiles examples"
  void $ launchAff tut12LM
  void $ launchAff tut12RM
  log "\nTut13 - Async Read/Write file example"
  void $ launchAff $
    fork (\e → AC.log $ "error: " <> e) (\_ → AC.log $ "success") app
