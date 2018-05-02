module Tut13 (app) where

import Prelude

import Control.Monad.Aff (Aff, nonCanceler)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Control.Monad.Eff.Exception (EXCEPTION, try)
import Control.Monad.Except.Trans (ExceptT, runExceptT)
import Data.Either (Either(..), either)
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (global)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile, writeTextFile)
import Task (newTask, rej, succ)

pathToFile :: String
pathToFile = "./resources/config.json"

readFile_
   :: ∀ a x e
    . Encoding → String
    → ExceptT String (Aff (fs :: FS, console :: CONSOLE, exception :: EXCEPTION | e)) String
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File: " <> filePath)
    result ← try $ readTextFile enc filePath
    cb $ either (\_ → rej "Can't read file") (\x → succ x) result
    pure $ nonCanceler

writeFile_
  :: ∀ e
   . Encoding → String → String
   → ExceptT String (Aff (fs :: FS, console :: CONSOLE, exception :: EXCEPTION | e)) String
writeFile_ enc filePath contents =
  newTask $
  \cb -> do
    Console.log ("Writing Contents: " <> contents)
    result ← try $ writeTextFile enc filePath contents
    cb $ either (\_ → rej "Can't read file") (\_ → succ "success") result
    pure $ nonCanceler

newContents :: String -> String
newContents s =
  case regexp of
    Left _ -> s
    Right r -> replace r "6" s
  where regexp = regex "8" global


app :: ∀ e. Aff (console :: CONSOLE, fs :: FS, exception :: EXCEPTION | e) Unit
app = do
  (runExceptT $
   readFile_ UTF8 pathToFile #
   map newContents >>=
   \x → writeFile_ UTF8 pathToFile x) >>=
  either (\e → log $ "error: " <> e) (\_ → log "successfully wrote file")
