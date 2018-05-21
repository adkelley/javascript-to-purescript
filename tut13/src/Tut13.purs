module Tut13 (app) where

import Prelude

import Control.Monad.Aff (Aff, nonCanceler)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Control.Monad.Eff.Exception (try)
import Data.Either (Either(..), either)
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (global)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile, writeTextFile)
import Control.Monad.Task (Task, newTask, rej, res, toAff)

pathToFile :: String
pathToFile = "./resources/config.json"

readFile_
  :: ∀ e
   . Encoding → String
   → Task String (fs :: FS, console :: CONSOLE | e) String
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\_ → rej "Can't read file") (\x → res x) result
    pure $ nonCanceler

writeFile_
  :: ∀ e
   . Encoding → String → String
   → Task String (fs :: FS, console :: CONSOLE | e)  String
writeFile_ enc filePath contents =
  newTask $
  \cb -> do
    Console.log ("Writing Contents: " <> contents)
    result ← try $ writeTextFile enc filePath contents
    cb $ either (\_ → rej "Can't write file") (\_ → res "wrote file") result
    pure $ nonCanceler

newContents :: String -> String
newContents s =
  case regexp of
    Left _ -> s
    Right r -> replace r "6" s
  where regexp = regex "8" global


app :: ∀ e. Aff (console :: CONSOLE, fs :: FS | e) Unit
app = do
  result ← toAff $
   readFile_ UTF8 pathToFile #
   map newContents >>=
   \x → writeFile_ UTF8 pathToFile x
  either (\e → log $ "error: " <> e) (\x → log $ "success: " <> x) result
