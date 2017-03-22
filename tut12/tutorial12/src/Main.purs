module Main where

import Prelude
import Control.Monad.Cont (Cont, cont, runCont)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Either (Either(..), either)

type Task = Either

taskOf :: forall a. a -> Task a a
taskOf = Right

taskRejected :: forall a. a -> Task a a
taskRejected = Left

taskCont :: forall a r. (Task a a) -> Cont r (Task a a)
taskCont t = cont $ \k -> k t

taskString :: Task Int Int -> Task String String
taskString (Left e) = Left (show e)
taskString (Right x) = Right (show x)

fork :: Task String String -> String
fork = either ("error: " <> _) ("success: " <> _)

launchMissiles :: Task String String
launchMissiles = taskOf $ "launch missile\n" <> "missile"

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Capture Side Effects in a Task"
  -- to witness Task.of(1) we run our callback function fork
  -- taskCont is just another synoymn for callback
  log $ runCont (taskCont $ taskOf 1) (taskString >>> fork)
  -- I can make a rejected Task with the rejected method here.
  log $ runCont (taskCont $ taskRejected 1) (taskString >>> fork)
  -- we can map over this, just like the other containery types
  log $ runCont (taskCont $ map (_ + 1) (taskOf 1)) (taskString >>> fork)
  -- We could also bind (aka chain) over it to return a task within a task
  let t = map (_ + 1) (taskOf 1) >>= (\x -> taskOf (x + 1))
  log $ runCont (taskCont t) (taskString >>> fork)
  -- Again, if we return the rejected version, it will just ignore both the map
  -- and the bind, and short circuit, and go right down to the error.
  let r = map (_ + 1) (taskRejected 1) >>= (\x -> taskOf (x + 1))
  log $ runCont (taskCont r) (taskString >>> fork)
  -- Let's launch some missiles
  let m = map (_ <> "!") launchMissiles
  log $ runCont (taskCont m) fork
  let app = map (_ <> "!") launchMissiles
  log $ runCont (taskCont $ (_ <> "!") <$> app) fork
