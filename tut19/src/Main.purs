module Main where

import Prelude
import Control.Apply (lift2)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Either (Either(..))

newtype Selector = Selector
  { selector :: String
  , height :: Int
  }

instance showSelector :: Show Selector where
  show (Selector s) = show s.height

-- jquery stub "$"
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
  Right (getScreenSize 800) `apply` (getSelector "header") `apply` (getSelector "footer")

result2 :: Either String Selector
result2 = lift2 (getScreenSize 800) (getSelector "header") (getSelector "footer")

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Applicative Functors for multiple arguments"
  logShow $ result1
  logShow $ result2
