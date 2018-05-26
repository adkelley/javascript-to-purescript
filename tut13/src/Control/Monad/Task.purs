module Control.Monad.Task
       (taskOf, taskRejected, newTask
       , res, rej, fork, chain, toAff, Task, TaskE)
       where

import Prelude

import Control.Monad.Aff (Aff, Canceler, Error, makeAff, throwError)
import Control.Monad.Eff (Eff)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..), either)

type Task e a = (Aff e) a

type TaskE x e a = ExceptT x (Aff e) a

taskOf :: ∀ x e a. a -> TaskE x e a
taskOf = pure

taskRejected :: ∀ x e a. x -> TaskE x e a
taskRejected = throwError

newTask
  ∷ ∀ e x a
  . ((Either Error (Either x a)
  → Eff e Unit) → Eff e (Canceler e)) → TaskE x e a
newTask =
  ExceptT <<< makeAff

toAff :: ∀ e x a. TaskE x e a → Aff e (Either x a)
toAff = runExceptT

fork
  :: ∀ c e b a
   . (a → Aff e c) → (b → Aff e c) → TaskE a e b
   → Task e c
fork f g t = do
  result ← toAff t
  either f g result

chain
  :: ∀ x e a b
   . (a → TaskE x e b) → TaskE x e a
   → TaskE x e b
chain f t =
  t >>= f

res :: ∀ e x b. b → Either x (Either e b)
res b = Right $ Right b

rej :: ∀ a x e. e → Either x (Either e a)
rej e = Right $ Left $ e
