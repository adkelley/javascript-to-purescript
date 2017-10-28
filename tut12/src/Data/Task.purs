module Data.Task
  ( Task
  , taskOf
  , taskRejected
  , taskCont
  , taskString
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

taskString :: Task Int Int -> Task String String
taskString (Left e) = Left (show e)
taskString (Right x) = Right (show x)

taskFork :: Task String String -> String
taskFork = either ("error: " <> _) ("success: " <> _)
