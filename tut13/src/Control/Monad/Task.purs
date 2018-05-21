module Control.Monad.Task
       (taskOf, taskRejected, newTask
       , res, rej, fork, chain, toAff, Task)
       where

import Prelude

import Control.Monad.Aff (Aff, Canceler, Error, makeAff, throwError)
import Control.Monad.Eff (Eff)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..), either)

type Task x e a = ExceptT x (Aff e) a

taskOf :: ∀ x e a. a -> Task x e a
taskOf = pure

taskRejected :: ∀ x e a. x -> Task x e a
taskRejected = throwError

newTask
  ∷ ∀ e x a
  . ((Either Error (Either x a)
  → Eff e Unit) → Eff e (Canceler e)) → Task x e a
newTask =
  ExceptT <<< makeAff

toAff :: ∀ e x a. Task x e a → Aff e (Either x a)
toAff = runExceptT

fork
  :: ∀ c e b a
   . (a → Aff e c) → (b → Aff e c) → Task a e b
   → Aff e c
fork f g t = do
  result ← toAff t
  either f g result

chain
  :: ∀ x e a b
   . (a → Task x e b) → Task x e a
   → Task x e b
chain f t =
  t >>= f

res :: ∀ e x b. b → Either x (Either e b)
res b = Right $ Right b

rej :: ∀ a x e. e → Either x (Either e a)
rej e = Right $ Left $ e
