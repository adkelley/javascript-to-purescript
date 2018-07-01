module Main where

import Prelude

import Control.Monad.Task (Task, TaskE, fork, taskOf, taskRejected)
import Data.Box (Box)
import Data.Either (Either)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Replacement(..), Pattern(..), replace)
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class.Console (log, logShow)
import Global (isNaN)

-- We use an unsafe prefix for parseFloat, because JS parseFloat
-- may return NaN.
foreign import unsafeParseFloat :: String -> Number


nanToMaybe :: Number → Maybe Number
nanToMaybe x =
  if (isNaN x)
    then Nothing
    else pure x

moneyToFloat :: String -> Maybe Number
moneyToFloat str =
  pure str -- Just str
  # map (replace (Pattern "$") (Replacement ""))
  # map (\replaced -> nanToMaybe $ unsafeParseFloat replaced)
  # join


-- | either.of(x) == pure x
-- | returns Right "hello"
eitherHello :: Either String String
eitherHello = pure "hello"

-- | returns Box "hello"
boxHello :: Box String
boxHello = pure "hello"

-- | returns TaskE a "hello" where a is a String
-- | taskOf == pure
taskHello :: TaskE String String
taskHello = taskOf "hello"

-- | returns TaskE "noHello" b, where b is a String
-- | taskRejected == throwError
taskNoHello :: TaskE String String
taskNoHello = taskRejected "no hello for you"

showTask :: TaskE String String → Task Unit
showTask =
  fork (\e → log $ "error: " <> e) (\y → log $ "success: " <> y)

main ::  Effect Unit
main = do
  log "Lift into a Functor with pure"
  logShow $ fromMaybe 0.0 $ moneyToFloat "$1.55"
  logShow $ fromMaybe 0.0 $ moneyToFloat "$NaN"
  logShow $ map (_ <> "!") eitherHello
  logShow boxHello
  log "\nTask is more interesting:"
  void $ launchAff $ showTask taskHello
  void $ launchAff $ showTask taskNoHello
