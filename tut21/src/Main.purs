module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res)
import Data.Array (elemIndex)
import Data.Either (Either(..), either)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler, throwError)
import Effect.Class.Console (log, error) as Console
import Effect.Console (log)
import Effect.Timer (setTimeout)

type Project = { id :: Int, title :: String }

-- | A quick review of Task
goodTask :: TaskE String String
goodTask = pure "good task"

badTask :: TaskE String String
badTask = throwError "bad task"


-- | Simulate a database query that returns a record with an id and a title
dbFind :: Int → TaskE String Project
dbFind id =
  let
    query :: Int → Effect (Either String Project)
    query id_ = pure $ do
      let validIds = [20, 8]
      case (elemIndex id_ validIds) of
        Just _  → Right { id: id_, title: "Project: " <> (show id)}
        Nothing → Left $ "record id: " <> (show id) <> " not found."
  in
   newTask $ \callback → do
     let requestResponse = query id >>= \r →
            callback $ either (\e → rej e) (\s → res s) r
     _ <- setTimeout 100 requestResponse
     pure $ nonCanceler

reportHeader :: Project -> Project -> String
reportHeader p1 p2 =
  foldr (<>) "" ["Report: ", p1.title, " compared to ", p2.title]


main :: Effect Unit
main = do
  log "Write applicative for concurrent actions"
  log "\nFirst a review of Task:"
  void $ launchAff $
     goodTask
     # fork (\e → Console.error e) (\r → Console.log $ "success: " <> r)
  void $ launchAff $
     badTask
     # fork (\e → Console.error $ "error: " <> e) (\r → Console.log $ "success: " <> r)

  void $ launchAff $
    let s = "\nTwo sequential finds using monads:\n"
    in
      dbFind 20 >>= (\p1 → (\p2 → reportHeader p1 p2) <$> dbFind 8)
      # fork (\e → Console.error $ s <> e) (\p → Console.log (s <> p))

  void $ launchAff $
    let s = "\nRewritten using two concurrent finds:\n"
    in
     (\p1 p2 → reportHeader p1 p2) <$> (dbFind 20) <*> (dbFind 8)
     # fork (\e → Console.error $ s <> "error - " <> e) (\p → Console.log (s <> p))

  void $ launchAff $
    let s = "\nRun an invalid record query:\n"
    in
     -- id 3 is invalid
     (\p1 p2 → reportHeader p1 p2) <$> (dbFind 8) <*> (dbFind 3)
     # fork (\e → Console.error $ s <> "error - " <> e) (\p → Console.log p)
