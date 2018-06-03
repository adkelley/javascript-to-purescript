module Tut13 (app) where

import Prelude

import Effect.Aff (nonCanceler)
import Effect.Class.Console (log)
import Effect.Exception (try)
import Control.Monad.Task (TaskE, chain, newTask, rej, res)
import Data.Either (Either(..), either)
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (global)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)

pathToFile :: String
pathToFile = "./resources/config.json"

readFile_
  :: Encoding → String
   → TaskE String String
readFile_ enc filePath =
  newTask $
  \cb -> do
    log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\err → rej $ show err) (\success → res success) result
    pure $ nonCanceler

writeFile_
  :: Encoding → String → String
   → TaskE String Unit
writeFile_ enc filePath contents =
  newTask $
  \cb -> do
    log ("Writing Contents: " <> contents)
    result ← try $ writeTextFile enc filePath contents
    cb $ either (\err → rej $ show err) (\success → res $ success) result
    pure $ nonCanceler

newContents :: String -> String
newContents s =
  case regexp of
    Left _ -> s
    Right r -> replace r "6" s
  where regexp = regex "8" global


app :: TaskE String Unit
app = do
  readFile_ UTF8 pathToFile
  # map newContents
  # chain (\x → writeFile_ UTF8 pathToFile x)
