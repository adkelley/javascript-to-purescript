module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (Error, try)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foreign (Foreign, ForeignError, parseJSON)
import Data.List.Types (NonEmptyList)
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)

type FilePath = String
type ErrorMessage = String
type PortNumber = String

fileName :: FilePath
fileName = "./resources/config.json"

defaultPort :: PortNumber
defaultPort = "3000"

foreign import getPortValue :: Foreign -> String

foldRead :: forall eff. (Either Error String) -> Eff (fs :: FS | eff) String
foldRead result =
  case result of
    (Left e) -> pure $ "{\"port\": " <> defaultPort <> "}"
    (Right x) -> pure x

foldJSON :: forall eff. (Either (NonEmptyList ForeignError) Foreign) -> Eff (fs :: FS | eff) String
foldJSON json =
  case json of
    (Left e) -> pure $ defaultPort
    (Right x) -> pure $ getPortValue x

getPort :: forall eff. Eff (fs :: FS | eff) String
getPort = do
  result <- try (readTextFile UTF8 fileName)
  jsonString <- foldRead result
  runExcept (parseJSON jsonString) #
  foldJSON

main :: forall e. Eff (console :: CONSOLE, fs :: FS | e) Unit
main = do
  log "Use bind for composable error handling with nested Eithers"
  log =<< getPort
