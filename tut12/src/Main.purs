module Main where

import Prelude
-- import Prelude hiding (add)

import Control.Monad.Cont (Cont, cont, runCont)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Either (Either(..), either)
import Data.Pythagoras (pythagoras, pythagorasCPS, pythagorasCont)
import Data.Thrice (thrice, thriceCont, thriceCPS)

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

addCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
addCPS x y = \k -> k (add x y)

addCont :: forall r. Int -> Int -> Cont r Int
addCont x y =
  pure (add x y)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "\n"
  log $ "Pythagoras without continuations: " <> (show $ pythagoras 3 4)
  log $ "Pythagoras with continuations: " <> (pythagorasCPS 3 4 show)
  log $ "Pythagoras with Cont monad: " <> (runCont (pythagorasCont 3 4) show)
  log "\n"
  log $ "Thrice without continuations: " <> (show $ thrice (add 1) 1)
  log $ "Thrice with continuations: " <> ((thriceCPS (addCPS 1) 1) show)
  log $ "Thrice with Cont monad: " <> (runCont (thriceCont (addCont 1) 1) show)
  log "\n"
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
