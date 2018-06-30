module Test (taskExample) where

import Prelude

import Control.Monad.Task (Task, taskOf, fork)
import Effect.Class.Console (log)

taskExample :: Task Unit
taskExample =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)
