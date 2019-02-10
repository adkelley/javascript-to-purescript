module Main where

import Prelude

import Control.Apply (lift2)
import Control.Monad.Task (TaskE, fork, newTask, res, rej)
import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (log) as Console
import Effect.Console (log)
import Effect.Timer (setTimeout)

type Project = { id :: Int, title :: String }


makeProject :: Int → String → Effect (Either String Project)
makeProject id title =
  pure $ Right { id: id, title: title }


find :: Int → TaskE String Project
find id =
  newTask $ \cb → do
    let project =
          makeProject id ("Project: " <> (show id)) >>=
          \p → cb $ either (\e → rej $ show e) (\s → res s) p
    _ <- setTimeout 100 project
    pure $ nonCanceler

reportHeader :: Project -> Project -> String
reportHeader p1 p2 = "Report: " <> p1.title <> " compared to " <> p2.title


main :: Effect Unit
main = do
  log "Write applicative for concurrent actions"
  void $ launchAff $
    lift2 (\p1 p2 → reportHeader p1 p2) (find 20) (find 39) #
    fork (\e → Console.log $ "error: " <> e) (\p → Console.log p)
