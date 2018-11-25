module Main where

import Prelude
import Control.Apply (lift2)
import Effect (Effect)
import Effect.Console (log)
import Data.Either (Either(..))

newtype Selector = Selector
  { selector :: String
  , height :: Int
  }

instance showSelector :: Show Selector where
  show (Selector s) = show s.height

-- fake jquery stub "$" and DOM node
getSelector :: String -> Either String Selector
getSelector selector =
  Right $ Selector { selector, height: 10 }

getScreenSize :: Int -> Selector -> Selector -> Selector
getScreenSize screen (Selector head) (Selector foot) =
  Selector { selector: "screen"
           , height:   screen - (head.height + foot.height)
           }

result1 :: Either String Selector
result1 =
  Right (getScreenSize 800) <*> (getSelector "header") <*> (getSelector "footer")

result2 :: Either String Selector
result2 = lift2 (getScreenSize 800) (getSelector "header") (getSelector "footer")

main ::  Effect Unit
main = do
  log "Applicative Functors for multiple arguments"
  log $ "result1: " <> (show result1)
  log $ "result2 (using lift2): " <> (show result2)
