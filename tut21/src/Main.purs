module Main where

import Prelude

import Control.Apply (lift2)
import Control.Monad.Task (TaskE, fork, newTask, res, rej)
import Data.Either (Either(..), either)
import Data.Foldable (foldr)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (log) as Console
import Effect.Console (log)
import Effect.Timer (setTimeout)

type Project = { id :: Int, title :: String }

-- | Simulate a database query using setTimeout
-- | to return a record with an id and a title
dbFind :: Int → TaskE String Project
dbFind id =
  let
    query :: Int → Effect (Either String Project)
    query id_ =
      pure $ Right { id: id_, title: "Project: " <> (show id)}
  in
   newTask $ \cb → do
     let response =
           query id >>= \r →
             cb $ either (\e → rej $ show e) (\s → res s) r
     _ <- setTimeout 100 response
     pure $ nonCanceler

reportHeader :: Project -> Project -> String
reportHeader p1 p2 =
  foldr (<>) "" ["Report: ", p1.title, " compared to ", p2.title]


main :: Effect Unit
main = do
  log "Write applicative for concurrent actions"
  void $ launchAff $
    let s = "\nTwo sequential finds:\n"
    in
      (dbFind 20) >>=
        (\p1 → (dbFind 8) >>=
           \p2 → pure $ reportHeader p1 p2)
      # fork (\e → Console.log $ "error: " <> e) (\p → Console.log (s <> p))

  void $ launchAff $
    let s = "\nRewritten using two concurrent finds:\n"
    in
     lift2 (\p1 p2 → reportHeader p1 p2) (dbFind 20) (dbFind 8)
     # fork (\e → Console.log $ "error: " <> e) (\p → Console.log (s <> p))
