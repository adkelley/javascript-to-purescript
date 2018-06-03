module Main where

import Prelude

import Effect.Aff (launchAff)
import Effect (Effect)
import Effect.Console (log)
import Effect.Class.Console (log) as Console
import Control.Monad.Task (fork)
import Tut12Aff (tut12Res, tut12Rej, tut12Chain, tut12LM, tut12RM)
import Tut13 (app)


main :: Effect Unit
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
    fork (\e → Console.log $ "error: " <> e) (\_ → Console.log $ "success") app
