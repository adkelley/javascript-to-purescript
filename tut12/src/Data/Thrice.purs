module Data.Thrice
 ( thrice
 , thriceCPS
 , thriceCont
 ) where

import Prelude
import Control.Monad.Cont (Cont)


-- A simple higher order function, no continuations
thrice :: forall a. (a -> a) -> a -> a
thrice f x = f (f (f x))

thriceCPS :: forall a r. (a -> ((a -> r) -> r)) -> a -> ((a -> r) -> r)
thriceCPS fCPS x = \k ->
  fCPS x $ \fx ->
  fCPS fx $ \fxx ->
  fCPS fxx $ k


thriceCont :: forall a r. (a -> Cont r a) -> a -> Cont r a
thriceCont fCont x = do
  fx <- fCont x
  fxx <- fCont fx
  fCont fxx
