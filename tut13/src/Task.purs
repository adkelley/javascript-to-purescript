module Task
       (taskOf, taskRejected, newTask
       , res, rej, toAff, TaskE, Task)
       where

import Prelude

import Control.Monad.Aff (Aff, Canceler, Error, makeAff, throwError)
import Control.Monad.Eff (Eff)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..))

type Task x a = ∀ e. ExceptT x (Aff e) a
type TaskE x e a = ExceptT x (Aff e) a

taskOf :: ∀ x a. a -> Task x a
taskOf = pure

taskRejected :: ∀ x a. x -> Task x a
taskRejected = throwError

newTask ∷ ∀ e x a. ((Either Error (Either x a) → Eff e Unit) → Eff e (Canceler e)) → TaskE x e a
newTask =
  ExceptT <<< makeAff

toAff :: ∀ e x a. TaskE x e a → Aff e (Either x a)
toAff = runExceptT

res :: ∀ e x b. b -> Either x (Either e b)
res b = Right $ Right b

rej :: ∀ a x e. e -> Either x (Either e a)
rej e = Right $ Left $ e
