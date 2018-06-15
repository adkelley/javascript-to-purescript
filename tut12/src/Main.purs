module Main where

import Prelude

import Control.Monad.Cont (runCont)
import Effect (Effect)
import Effect.Console (log)
import Data.Pythagoras (pythagoras, addCPS, addCont, pythagorasCPS, pythagorasCont)
import Data.Task (contTask, taskFork, taskOf, taskRejected)
import Data.Thrice (thrice, thriceCont, thriceCPS)

main :: Effect Unit
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
  -- `err`, and `success` are two separate continuation functions,
  --  one of which will be invoked by `k`, our top-level continuation.
  let success = \x -> "success: " <> show x
  let err = \e -> "error: " <> show e
  let fork = taskFork err success
  let k = fork >>> log

  -- To witness TaskOf(1.0) we call 'runCont c k', which will
  -- run the computation contained in 'c' and invoke 'success',
  -- which is nested in our top-level continuation 'k'

  let c0 = contTask $ taskOf 1.0
  runCont c0 k
  -- I can make a rejected Task with the rejected method here.
  -- Thus err will be invoked
  let c1 = contTask $ taskRejected 1.0
  runCont c1 k

  -- add a prefix string 'p' to our top-level continuation 'k'
  -- we'll need a new 'k' var in order to avoid a shadow warning
  let k' p = fork >>> \s -> log $ p <> s

  -- we can map over this, just like the other container types
  let c2 = contTask $ (taskOf 1.0) # map (_ + 1.0)
  runCont c2 (k' "Task.of.map: ")
  -- We could also bind >>= (aka chain) over it to return a task within a task
  let c3 = contTask $
          (taskOf 1.0) #
          map (_ + 1.0) >>=
          \x -> taskOf (x + 1.0)
  runCont c3 (k' "taskOf.map.chain.taskOf: ")
  -- Again, if we return the rejected version, it will short circuit, ignoring
  -- both map and the second task, and go right down to the error.
  let c4 = contTask $
          (taskRejected 1.0) #
          map (_ + 1.0) >>=
          \x -> taskOf (x + 1.0)
  runCont c4 (k' "Task.rejected.map.chain.Task.of: ")
  -- We can even reject anywhere along the way
  let c5 = contTask $ (taskOf 1.0) #
          map (_ + 1.0) >>=
          \x -> taskRejected (x + 1.0)
  runCont c5 (k' "taskOf.map.chain.taskRejected: ")


  log "\nLet's launch some missiles!"
  -- we'll need new success and err continuations
  -- because we're returning String instead of Int
  let err' = \e -> "error: " <> e
  let success' = \x -> "success: " <> x
  let fork' = taskFork err' success'

  let sideEffects = \t -> do
        log "launch missiles!"
        log t

  let r1 = taskOf "missle" # map (_ <> "!")
  -- I can delay the side effects, and even extend
  -- the computation before it runs.
  let c6 = contTask $ r1 # map (_ <> "!")
  runCont c6 (fork' >>> sideEffects)
