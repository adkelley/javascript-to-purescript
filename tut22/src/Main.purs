module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res)
import Data.Either (Either, either)
import Data.Foldable (foldl)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (log, errorShow) as Console
import Effect.Console (log)
import Effect.Exception (Error, try)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)

pathToFile :: String
pathToFile = "./resources/"

files :: Array String
files = map (\x → pathToFile <> x) ["Box.purs", "config.json"]

taskReadTextFile :: String → TaskE Error String
taskReadTextFile fname =
  let
    tryReadTextFile :: String → Effect (Either Error String)
    tryReadTextFile fname_ = try $ readTextFile UTF8 fname_
  in
    newTask $ \callback → do
      tryReadTextFile fname >>= \r →
        callback $ either (\e → rej e) (\s → res s) r
      pure $ nonCanceler


main :: Effect Unit
main = do
  log "Tutorial 22: Leapfrogging types with Traverse"
  void $ launchAff $
    traverse (\x → taskReadTextFile x) files
    # fork (\e → Console.errorShow e) (\rs → Console.log $ foldl (<>) "" rs)
