module Data.Pythagoras
  ( pythagoras
  , pythagorasCPS
  , pythagorasCont
  , addCPS
  , addCont
  )
  where

import Prelude

import Control.Monad.Cont (Cont)

-- No continuations
square :: Int -> Int
square x = x * x

pythagoras :: Int -> Int -> Int
pythagoras x y = add (square x) (square y)

-- Continuations
addCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
addCPS x y = \k -> k (add x y)

squareCPS :: forall r. Int -> ((Int -> r) -> r)
squareCPS x = \k -> k (square x)

pythagorasCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
pythagorasCPS x y = \k ->
  squareCPS x $ \xSquared ->
  squareCPS y $ \ySquared ->
  (addCPS xSquared ySquared) k

addCont :: forall r. Int -> Int -> Cont r Int
addCont x y =
  pure (add x y)

squareCont :: forall r. Int -> Cont r Int
squareCont x =
  pure (square x)

pythagorasCont :: forall r. Int -> Int -> Cont r Int
pythagorasCont x y = do
  xSquared <- squareCont x
  ySquared <- squareCont y
  addCont xSquared ySquared
