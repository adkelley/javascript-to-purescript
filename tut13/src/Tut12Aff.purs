module Tut12Aff (tut12App, tut12LM, tut12RM) where

import Prelude

import Control.Monad.Aff (Aff, nonCanceler)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Control.Monad.Except.Trans (ExceptT, runExceptT)
import Data.Either (either)
import Task (taskOf, taskRejected, newTask, succ, rej, toAff)

tut12App :: ∀ eff. Aff (console :: CONSOLE | eff) Unit
tut12App = do
  (toAff $ taskOf "hello") >>=
  either (\e -> log $ "err " <> e) (\x -> log $ "success " <> x)
  (toAff $ taskRejected 1) >>=
  either (\e -> log $ "err " <> show e) (\x -> log $ "success " <> x)

  -- Task (Task)
  (toAff $ taskOf 1 # map (_ + 1) >>= \x → taskOf (x + 1)) >>=
  either (\e → log $ "err " <> e) (\x → log $ "success " <> show x)


launchMissiles :: ∀ x e. ExceptT x (Aff (console :: CONSOLE | e)) String
launchMissiles =
  newTask \cb → do
      Console.log "\nLaunch Missiles"
      cb $ succ "missile"
      pure nonCanceler

rejectMissiles :: ∀ e a. ExceptT String (Aff (console :: CONSOLE | e)) a
rejectMissiles =
  newTask \cb → do
      Console.log "\nLaunch Missiles"
      cb $ rej "missile failed"
      pure nonCanceler

tut12LM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12LM =
  (runExceptT $ do
   launchMissiles #
   map (_ <> "!") #
   map (_ <> "!")) >>=
   either (\e → log $ "err " <> e) (\x → log $ "success " <> show x)

tut12RM :: ∀ aff. Aff (console :: CONSOLE | aff) Unit
tut12RM = (runExceptT $
  rejectMissiles #
  map (_ <> "!") #
  map (_ <> "!")) >>=
  either (\e → log $ "err " <> show e) (\x → log $ "success " <> x)
