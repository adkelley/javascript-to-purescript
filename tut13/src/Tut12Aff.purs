module Tut12Aff ( tut12Res, tut12Rej, tut12Chain
                , tut12LM, tut12RM) where

import Prelude

import Effect.Aff (nonCanceler)
import Effect.Class.Console (log)
import Control.Monad.Task (Task, TaskE, taskOf, taskRejected, newTask, res, rej, fork, chain)

tut12Res :: Task Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: Task Unit
tut12Rej =
  taskRejected "bad task"
  # fork (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

tut12Chain :: Task Unit
tut12Chain =
  taskOf 1
  # map (_ + 1)
  # chain (\x → taskOf (x + 1))
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)


launchMissiles :: ∀ x. TaskE x String
launchMissiles =
  newTask \cb → do
      log "\nLaunch Missiles"
      cb $ res "missile"
      pure nonCanceler

rejectMissiles :: ∀ a. TaskE String a
rejectMissiles =
  newTask \cb → do
      log "\nLaunch Missiles"
      cb $ rej "missile failed"
      pure nonCanceler

tut12LM :: Task Unit
tut12LM = do
  launchMissiles
  # map (_ <> "!")
  # map (_ <> "!")
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12RM :: Task Unit
tut12RM = do
  rejectMissiles
  # map (_ <> "!")
  # map (_ <> "!")
  # fork (\e → log $ "err " <> show e) (\x → log $ "success " <> x)
