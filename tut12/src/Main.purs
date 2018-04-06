module Main where

import Prelude

import Control.Monad.Cont (runCont)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Pythagoras (pythagoras, addCPS, addCont, pythagorasCPS, pythagorasCont)
import Data.Task (Task, taskOf, taskRejected, taskCont, taskFork)
import Data.Thrice (thrice, thriceCont, thriceCPS)

launchMissiles :: Task String String
launchMissiles = taskOf $ "launch missiles -> " <> "missile"

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  -- See https://en.wikibooks.org/wiki/Haskell/Continuation_passing_style
  log $ "\nPythagoras direct style: " <> (show $ pythagoras 3 4)
  pythagorasCPS 3 4 \k ->
    log $ "Pythagoras with continuations: " <> show k
  runCont (pythagorasCont 3 4) \k ->
    log $ "Pythagoras with Cont monad: " <> show k

  log $ "\nThrice direct style: " <> (show $ thrice (add 1) 1)
  thriceCPS (addCPS 1) 1 \k ->
    log $ "Thrice with continuations: " <> show k
  runCont (thriceCont (addCont 1) 1) \k ->
    log $ "Thrice with Cont monad: " <> show k

  log "\nCapture Side Effects in a Task"
  -- To witness Task.of(1) we run our callback function fork
  -- taskCont is just another synoymn for callback
  -- log $ "Task.of: " <> (runCont (taskCont $ taskOf 1) (taskString >>> taskFork))
  runCont (taskCont $ taskOf 1.0) $ taskFork >>> \k ->
    log $ "Task.of: " <> k
  -- -- I can make a rejected Task with the rejected method here.
  runCont (taskCont $ taskRejected 1) $ taskFork >>> \k ->
    log $ "Task.rejected: " <> k
  -- we can map over this, just like the other containery types
  runCont (taskCont $ (_ + 1) <$> (taskOf 1)) $ taskFork >>> \k ->
    log $ "Task.of.map: " <> k
  -- We could also bind >>= (aka chain) over it to return a task within a task
  let t = (_ + 1) <$> (taskOf 1) >>= (\x -> taskOf (x + 1))
  runCont (taskCont t) $ taskFork >>> \k ->
    log $ "Task.of.map.chain: " <> k
  -- Again, if we return the rejected version, it will just ignore both the map
  -- and the bind, and short circuit, and go right down to the error.
  let r = map (_ + 1) (taskRejected 1) >>= (\x -> taskOf (x + 1))
  runCont (taskCont r) $ taskFork >>> \k ->
    log $ "Task.rejected.map.chain: " <> k

  log "\nLet's launch some missiles"
  let m = map (_ <> "!") launchMissiles
  runCont (taskCont m) $ taskFork >>> \k -> log k
  let app = map (_ <> "!") launchMissiles
  log $ runCont (taskCont $ (_ <> "!") <$> app) taskFork
