module Task
       (taskOf, taskRejected
       , newTask, succ, rej)
       where

import Prelude

import Control.Monad.Aff (Aff, Canceler, Error, makeAff, throwError)
import Control.Monad.Aff.Class (liftAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Except.Trans (ExceptT(..))
import Data.Either (Either(..))

type Task x a = ∀ e. ExceptT x (Aff e) a

taskOf :: ∀ x a. a -> Task x a
taskOf = pure

taskRejected :: ∀ x a. x -> Task x a
taskRejected = throwError

newTask ∷ ∀ e x a. ((Either Error (Either x a) → Eff e Unit) → Eff e (Canceler e)) → ExceptT x (Aff e) a
newTask =
  ExceptT <<< liftAff <<< makeAff

succ :: ∀ e x b. b -> Either x (Either e b)
succ b = Right $ Right b

rej :: ∀ a x e. e -> Either x (Either e a)
rej e = Right $ Left $ e
