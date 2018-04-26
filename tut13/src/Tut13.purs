module Tut13 (app) where

import Prelude

import Control.Monad.Aff (Aff, Error, attempt, nonCanceler)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff.Console (log) as Console
import Data.Either (Either(..), either)
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (global)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (FS, readTextFile, writeTextFile)
import TaskAff (newTask)

pathToFile :: String
pathToFile = "./resources/config.json"

readFile_
  :: ∀ eff
   . Encoding → String
   → Aff (console :: CONSOLE | eff) (Aff (fs :: FS | eff) (Either Error String))
readFile_ enc filePath =
  newTask $
  \cb -> do
    Console.log ("\nReading File")
    cb $ Right $ attempt $ readTextFile enc filePath
    pure $ nonCanceler

writeFile_
  :: ∀ eff
   . Encoding → String → String
   → Aff (console :: CONSOLE | eff) (Aff (fs :: FS | eff) (Either Error Unit))
writeFile_ enc filePath contents =
  newTask $
  \cb -> do
    Console.log ("\nWriting File: " <> contents)
    cb $ Right $ attempt $ writeTextFile enc filePath contents
    pure $ nonCanceler

newContents :: String -> String
newContents s =
  case regexp of
    Left _ -> s
    Right r -> replace r "6" s
  where regexp = regex "8" global


app :: ∀ e. Aff (console :: CONSOLE, fs :: FS | e) Unit
app = do
  readFile_ UTF8 pathToFile >>= map id >>=
  either (\e → log "error")
         (\x → do
               let y = newContents x
               writeFile_ UTF8 pathToFile y >>= map id >>=
               either (\e → log "error") (\_ → log "success")
         )
