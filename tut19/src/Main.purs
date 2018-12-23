module Main where

import Prelude

import Control.Apply (lift2)
import Data.Either (Either)
import Effect (Effect)
import Effect.Console (log)

type Error = String

newtype Selector = Selector
  { selector :: String
  , height :: Int
  }

instance showSelector :: Show Selector where
  show (Selector s) = show s.height

-- fake jquery stub "$" and DOM node
getSelector :: String -> Either Error Selector
getSelector selector =
  pure $ Selector { selector, height: 10 }

getScreenSize :: Int -> Selector -> Selector -> Selector
getScreenSize screen (Selector header) (Selector footer) =
  Selector { selector: "screen"
           , height:   screen - (header.height + footer.height)
           }

-- | Use the Monad type constructor to sequentially acquire
-- | the header and the footer size
result1A :: Either Error Selector
result1A =
   (getSelector "header") >>=
      \header -> (getSelector "footer") >>=
         \footer -> pure $ getScreenSize 800 header footer

result1B :: Either Error Selector
result1B = do
  header <- getSelector "header"
  footer <- getSelector "footer"
  pure $ getScreenSize 800 header footer

-- | Better to acquire the header and footer in parallel,
-- | using the Applicative Functor
result2 :: Either Error Selector
result2 =
  pure (getScreenSize 800) <*> (getSelector "header") <*> (getSelector "footer")

-- | Shorten result2 by using lift2
result3 :: Either Error Selector
result3 = lift2 (getScreenSize 800) (getSelector "header") (getSelector "footer")

-- | Use Applicative do-notation (syntax support added in 0.12)
result4 :: Either Error Selector
result4 = ado
  header ← getSelector "header"
  footer ← getSelector "footer"
  in getScreenSize 800 header footer

main ::  Effect Unit
main = do
  log "Applicative Functors for multiple arguments"
  log $ "result1A (uses >>=): " <> (show result1A)
  log $ "result1b (uses a 'do block'): " <> (show result1B)
  log $ "result2 (uses <*>): " <> (show result2)
  log $ "result3 (uses lift2): " <> (show result3)
  log $ "result4 (uses ado): " <> (show result4)
