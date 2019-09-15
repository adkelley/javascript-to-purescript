module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res)
import Data.Either (Either, either)
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence, traverse)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (log, errorShow) as Console
import Effect.Console (log, logShow)
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

  log "\nExamples of sequence and traverse:"
-- The sequence method flips the structures around: Array (Maybe Int) -> Maybe (Array Int)"
  logShow $ sequence [Just 1, Just 2, Just 3] -- returns Just [1, 2, 3]
  logShow $ sequence [Just 1, Nothing, Just 3] -- returns Nothing
  let fn = \x -> if (x > 0) then (Just x) else Nothing
-- The traverse method performs an action on the elements then, like sequence, flips the
-- structures around: Array (Maybe Int) -> Maybe (Array Int)"
  logShow $ traverse fn [1, 2, 3] -- returns Just [1, 2, 3]
  logShow $ traverse fn [1, -1, 3] -- returns Nothing

  void $ launchAff $
    traverse (\x → taskReadTextFile x) files #
    fork (\e → Console.errorShow e) (\rs → Console.log $ foldl (<>) "" rs)
