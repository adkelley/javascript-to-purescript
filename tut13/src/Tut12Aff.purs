module Tut12Aff (tut12App, tut12LM, tut12RM) where

import Prelude

import Control.Monad.Aff (Aff, Error, makeAff, nonCanceler, try)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Data.Either (Either, either)
import TaskAff (taskOf, taskRejected, newTask, succ, rej)

tut12App :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12App = do
  a1 ← try $ taskOf "hello"
  either (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x) a1
  a2 ← try $ taskRejected 1
  either (\e -> log $ "err " <> show e) (\x -> log $ "success " <> show x) a2

  -- Task (Task)
  (try $ taskOf 1) >>=
    map (_ + 1) >>>
    taskOf <<< map (_ + 1) >>=
    either (\e → log $ "err " <> show e) (\x → log $ "success " <> show x)


launchMissiles :: ∀ aff. Aff (console :: CONSOLE | aff) (Either Error String)
launchMissiles =
  newTask \cb → do
      Console.log "\nLaunch Missiles"
      cb $ succ "missile"
      pure nonCanceler

rejectMissiles :: ∀ aff. Aff (console :: CONSOLE | aff) (Either String String)
rejectMissiles =
  makeAff \cb → do
      Console.log "\nLaunch Missiles"
      cb $ rej "missile"
      pure nonCanceler

tut12LM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12LM = do
  launchMissiles >>=
    map (_ <> "!") >>>
    map (_ <> "!") >>>
    either (\e → log $ "err " <> show e) (\x → log $ "success " <> show x)

tut12RM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12RM = do
  rejectMissiles >>=
    map (_ <> "!") >>>
    map (_ <> "!") >>>
    either (\e → log $ "err " <> e) (\x → log $ "success " <> show x)
