module Main where

import Prelude

import Control.Apply (lift2)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Console (log)

newtype Selector = Selector
  { selector :: String
  , height :: Int
  }

type Error = String

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

-- | Use the Monad type constructor to sequentially acquire
-- | the header and the footer size
result1 :: Either Error Selector
result1 =
  Right ()

-- | Better
result2 :: Either Error Selector
result2 =
  Right (getScreenSize 800) <*> (getSelector "header") <*> (getSelector "footer")

result3 :: Either Error Selector
result3 = lift2 (getScreenSize 800) (getSelector "header") (getSelector "footer")

main ::  Effect Unit
main = do
  log "Applicative Functors for multiple arguments"
  log $ "result2 (using <*>): " <> (show result1)
  log $ "result3 (using lift2): " <> (show result2)
