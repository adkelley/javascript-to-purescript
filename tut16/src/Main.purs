module Main where

import Prelude

import Data.Box (Box(..))
import Effect (Effect)
import Effect.Console (log)

-- | Monad associativity law
-- | (m >>= f) >>= g ≡ m >>= (\x → f x >>= g)
m1 :: Box (Box (Box Int))
m1 = pure $ pure $ pure 3

result1 :: Box Int
result1 = (m1 >>= identity) >>= identity

result2 :: Box Int
result2 = m1 >>= (\x → identity x >>= identity)

-- | Monad Identity laws
-- | Right: m >>= pure ≡ m
-- | Left: pure a >>= f ≡ f a

m2 :: Box String
m2 = pure "Wonder"

rightIdentity :: Boolean
rightIdentity =  (m2 >>= pure) == m2

leftIdentity :: Boolean
leftIdentity = (m2 >>= Box) == (Box "Wonder")

main :: Effect Unit
main = do
  log "You've been using Monads"
  log $ "(m >>= f) >>= g : " <> (show result1)
  log $ "m >>= (\\x → f x >>= g) : " <> (show result2)
  log $ "Associativity law:  " <> (show $ result1 == result2)
  log $ "Right Identity law: " <> (show rightIdentity)
  log $ "Left Identity law:  " <> (show leftIdentity)
