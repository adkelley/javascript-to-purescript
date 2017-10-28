module Main where

import Prelude

import Control.Monad.Cont (Cont, runCont)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Task (Task, taskOf, taskRejected, taskCont, taskString, taskFork)
import Data.Pythagoras (pythagoras, pythagorasCPS, pythagorasCont)
import Data.Thrice (thrice, thriceCont, thriceCPS)

launchMissiles :: Task String String
launchMissiles = taskOf $ "launch missile\n" <> "missile"

addCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
addCPS x y = \k -> k (add x y)

addCont :: forall r. Int -> Int -> Cont r Int
addCont x y =
  pure (add x y)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log $ "\nPythagoras without continuations: " <> (show $ pythagoras 3 4)
  log $ "Pythagoras with continuations: " <> (pythagorasCPS 3 4 show)
  log $ "Pythagoras with Cont monad: " <> (runCont (pythagorasCont 3 4) show)
  log $ "\nThrice without continuations: " <> (show $ thrice (add 1) 1)
  log $ "Thrice with continuations: " <> ((thriceCPS (addCPS 1) 1) show)
  log $ "Thrice with Cont monad: " <> (runCont (thriceCont (addCont 1) 1) show)
  log "\nCapture Side Effects in a Task"
  -- to witness Task.of(1) we run our callback function fork
  -- taskCont is just another synoymn for callback
  log $ runCont (taskCont $ taskOf 1) (taskString >>> taskFork)
  -- I can make a rejected Task with the rejected method here.
  log $ runCont (taskCont $ taskRejected 1) (taskString >>> taskFork)
  -- we can map over this, just like the other containery types
  log $ runCont (taskCont $ map (_ + 1) (taskOf 1)) (taskString >>> taskFork)
  -- We could also bind (aka chain) over it to return a task within a task
  let t = map (_ + 1) (taskOf 1) >>= (\x -> taskOf (x + 1))
  log $ runCont (taskCont t) (taskString >>> taskFork)
  -- Again, if we return the rejected version, it will just ignore both the map
  -- and the bind, and short circuit, and go right down to the error.
  let r = map (_ + 1) (taskRejected 1) >>= (\x -> taskOf (x + 1))
  log $ runCont (taskCont r) (taskString >>> taskFork)
  -- Let's launch some missiles
  let m = map (_ <> "!") launchMissiles
  log $ runCont (taskCont m) taskFork
  let app = map (_ <> "!") launchMissiles
  log $ runCont (taskCont $ (_ <> "!") <$> app) taskFork
