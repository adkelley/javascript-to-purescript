module Data.Task
  ( Task
  , taskOf
  , taskRejected
  , taskCont
  , taskFork
  ) where

import Prelude

import Control.Monad.Cont (Cont, cont)
import Data.Either (Either(..), either)

type Task = Either

taskOf :: forall a. a -> Task a a
taskOf = Right

taskRejected :: forall a. a -> Task a a
taskRejected = Left

taskCont :: forall a r. (Task a a) -> Cont r (Task a a)
taskCont t = cont $ \k -> k t

taskFork :: forall a. Show a => Task a a -> String
taskFork = either (\e -> "error: " <> show e) (\x -> "success: " <> show x)
