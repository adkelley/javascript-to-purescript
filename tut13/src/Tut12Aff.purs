module Tut12Aff ( tut12Res, tut12Rej, tut12Chain
                , tut12LM, tut12RM) where

import Prelude

import Control.Monad.Aff (Aff, nonCanceler)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Task (TaskE, taskOf, taskRejected, newTask, res, rej, fork, chain)

tut12Res :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
tut12Res =
  taskOf "good task"
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12Rej :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
tut12Rej =
  taskRejected "bad task"
  # fork (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

tut12Chain :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
tut12Chain =
  taskOf 1
  # map (_ + 1)
  # chain (\x → taskOf (x + 1))
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)


launchMissiles :: ∀ x e. TaskE x (console :: CONSOLE | e) String
launchMissiles =
  newTask \cb → do
      Console.log "\nLaunch Missiles"
      cb $ res "missile"
      pure nonCanceler

rejectMissiles :: ∀ e a. TaskE String (console :: CONSOLE | e) a
rejectMissiles =
  newTask \cb → do
      Console.log "\nLaunch Missiles"
      cb $ rej "missile failed"
      pure nonCanceler

tut12LM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12LM = do
  launchMissiles
  # map (_ <> "!")
  # map (_ <> "!")
  # fork (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12RM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12RM = do
  rejectMissiles
  # map (_ <> "!")
  # map (_ <> "!")
  # fork (\e → log $ "err " <> show e) (\x → log $ "success " <> x)
