module Tut13 (app) where

import Prelude

import Control.Monad.Aff (nonCanceler)
import Control.Monad.Aff.Console (CONSOLE)
import Control.Monad.Eff.Console (log) as Console
import Control.Monad.Eff.Exception (try)
import Control.Monad.Task (TaskE, chain, newTask, rej, res)
import Data.Either (Either(..), either)
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (global)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile, writeTextFile)

pathToFile :: String
pathToFile = "./resources/config.json"

readFile_
  :: ∀ e
   . Encoding → String
   → TaskE String (fs :: FS, console :: CONSOLE | e) String
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\e → rej $ show e) (\success → res success) result
    pure $ nonCanceler

writeFile_
  :: ∀ e
   . Encoding → String → String
   → TaskE String (fs :: FS, console :: CONSOLE | e)  String
writeFile_ enc filePath contents =
  newTask $
  \cb -> do
    Console.log ("Writing Contents: " <> contents)
    result ← try $ writeTextFile enc filePath contents
    cb $ either (\e → rej $ show e) (\_ → res "wrote file") result
    pure $ nonCanceler

newContents :: String -> String
newContents s =
  case regexp of
    Left _ -> s
    Right r -> replace r "6" s
  where regexp = regex "8" global


app :: ∀ e. TaskE String (console :: CONSOLE, fs :: FS | e) String
app = do
  readFile_ UTF8 pathToFile
  # map newContents
  # chain (\x → writeFile_ UTF8 pathToFile x)
