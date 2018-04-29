module TaskAff
       ( Task, taskOf, taskRejected
       , newTask, succ, rej)
       where

import Prelude

import Control.Monad.Aff (Aff, Canceler, Error, error, makeAff, throwError)
import Control.Monad.Eff (Eff)
import Data.Either (Either(..))

type Task a = ∀ aff. (Aff aff) a

taskOf :: ∀ a. a -> Task a
taskOf = pure

taskRejected :: ∀ a. Show a => a -> Task a
taskRejected x = throwError (error $ show x)

newTask :: ∀ eff a. ((Either Error a → Eff eff Unit) → Eff eff (Canceler eff)) → Aff eff a
newTask =
  makeAff

succ :: ∀ e b. b -> Either Error (Either e b)
succ b = Right $ Right b

rej :: ∀ a e. Show e => e -> Either Error (Either String a)
rej e = Right $ Left $ show e
