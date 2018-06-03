module Main where

import Prelude
import Data.Either (Either)
import Effect (Effect)
import Effect.Console (log, logShow)

-- either.of(x) == pure x
eitherOf :: String -> Either String String
eitherOf = pure

eitherExample :: Either String String
eitherExample =
  eitherOf "hello" #
  -- map (\x -> x <> "!")
  map (_ <> "!")


main ::  Effect Unit
main = do
  log "Lift into a Pointed Functor with of"
  logShow eitherExample
