module Main where

import Prelude
import Data.Either (Either)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)

eitherOf :: String -> Either String String
eitherOf = pure

eitherExample :: Either String String
eitherExample =
  eitherOf "hello" #
  map (\x -> x <> "!")

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Lift into a Pointed Functor with of"
  logShow eitherExample
