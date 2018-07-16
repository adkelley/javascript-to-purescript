module Main where

import Prelude

import Data.Box (Box(..))
import Effect (Effect)
import Effect.Console (log)

-- | Let's alias Task to Box
-- | to avoid asynchronious computation
type Task = Box

type Comments = Array String
type User = { name     :: String
            , id       :: String
            , comments :: Comments
            }

alex :: User
alex = { name: "alex"
       , id: "112"
       , comments: ["great blog", "good job"]
       }


-- | mocking the first REST call
httpGet1 :: String → Task User
httpGet1 _ = pure alex

-- | mocking the second REST call
httpGet2 :: String → Task Comments
httpGet2 _ = pure alex.comments


getComments1 :: Task (Task Comments)
getComments1 =
  httpGet1 "/user"
  # map \user → httpGet2 $ "/comments/" <> user.id


getComments2 :: Task Comments
getComments2 =
  httpGet1 "/user" >>= \user → httpGet2 $ "/comments" <> user.id


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
  log "\nHttpGet Example:"
  log $ show getComments1
  log $ show getComments2
  log "\nMonad laws:"
  log $ "(m >>= f) >>= g : " <> (show result1)
  log $ "m >>= (\\x → f x >>= g) : " <> (show result2)
  log $ "Associativity law:  " <> (show $ result1 == result2)
  log $ "Right Identity law: " <> (show rightIdentity)
  log $ "Left Identity law:  " <> (show leftIdentity)
