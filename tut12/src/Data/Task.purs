module Data.Task
  ( Task
  , taskOf
  , taskRejected
  , taskFork
  , contTask
  ) where

import Prelude

import Control.Monad.Cont (Cont)
import Data.Either (Either(..), either)

type Task = Either

-- mapTask :: forall a b c r. (b -> c) -> Cont r (Task a b) -> Cont r (Task a c)
-- mapTask f = (map <<< map) f

-- taskOf :: forall a b r. b -> Cont r (Task a b)
-- taskOf b = pure (Right b)

-- taskRejected :: forall a b r. a -> Cont r (Task a b)
-- taskRejected a = pure (Left a)

taskOf :: forall a b. b -> Task a b
taskOf = Right

taskRejected :: forall a b. a -> Task a b
taskRejected = Left

contTask :: forall a b r. (Task a b) -> Cont r (Task a b)
contTask = pure

-- runTask :: forall a b c r. Task a b -> (c -> r) -> r
-- runTask t f = runCont (contTask t) f

taskFork :: forall a b c. (a -> c) -> (b -> c) -> Task a b -> c
taskFork f g = either f g
