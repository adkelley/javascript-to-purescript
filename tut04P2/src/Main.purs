module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Effect.Exception (Error, error, try)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Foreign (unsafeFromForeign)
import Simple.JSON (parseJSON)
import Data.List.NonEmpty (head)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)

pathToFile :: String
pathToFile = "./resources/config.json"

newtype Port = Port { port :: Int }
instance showPort :: Show Port where
  show (Port { port }) = show port

defaultPort :: Port
defaultPort = Port { port: 3000 }

portInRange :: Port -> Either Error Port
portInRange (Port { port }) =
  if (port >= 1000 && port <= 8888)
    then Right $ (Port { port })
    else Left $ error "Port number out of range"

parsePort :: String -> Either Error Port
parsePort port =
  case parsed of
    Left nel -> Left $ error $ show $ head nel
    Right x -> Right $ unsafeFromForeign x :: Port
  where parsed = runExcept $ parseJSON port


chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f  = either (\e -> Left e) (\x -> (f x))


getPort :: Effect Port
getPort =
  (try $ readTextFile UTF8 pathToFile) >>=
  chain parsePort >>>
  chain portInRange >>>
  either (\_ -> defaultPort) identity >>>
  pure

-- Instead or ignoring errors and returning defaultPort, try creating a JSON string
-- error or read file error and then use this modified getport function below to log
-- the error to the console.

getPort' :: Effect (Either Error Port)
getPort' =
  (try $ readTextFile UTF8 pathToFile) >>=
  chain parsePort >>>
  chain portInRange >>>
  pure


main :: Effect Unit
main = do
  log "Use chain for composable error handling with nested Eithers"

  -- Code Example 1: using bind and bundFlipped respectively
  (try $ readTextFile UTF8 pathToFile) >>= logShow
  logShow =<< (try $ readTextFile UTF8 pathToFile)

    -- Code Example 2
  getPort >>= logShow
