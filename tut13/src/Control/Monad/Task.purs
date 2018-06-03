module Control.Monad.Task
       (taskOf, taskRejected, newTask
       , res, rej, fork, chain, Task, TaskE)
       where

import Prelude

import Effect.Aff (Aff, Canceler, Error, makeAff, throwError)
import Effect (Effect)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..), either)

type Task a = Aff a

type TaskE x a = ExceptT x Aff a

taskOf :: ∀ x a. a -> TaskE x a
taskOf = pure

taskRejected :: ∀ x a. x -> TaskE x a
taskRejected = throwError

newTask
  ∷ ∀ x a
  . ((Either Error (Either x a)
  → Effect Unit) → Effect Canceler) → TaskE x a
newTask =
  ExceptT <<< makeAff

toAff :: ∀ x a. TaskE x a → Aff (Either x a)
toAff = runExceptT

fork
  :: ∀ c b a
   . (a → Aff c) → (b → Aff c) → TaskE a b
   → Task c
fork f g t = do
  result ← toAff t
  either f g result

chain
  :: ∀ x a b
   . (a → TaskE x b) → TaskE x a
   → TaskE x b
chain f t =
  t >>= f

res :: ∀ x b e. b → Either x (Either e b)
res b = Right $ Right b

rej :: ∀ a x e. e → Either x (Either e a)
rej e = Right $ Left $ e
