module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res)
import Data.Array (drop, length, head)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (error, logShow) as Console
import Effect.Console (log, logShow)
import Node.Process (argv)
import Spotify (RelatedNames, findArtist, relatedArtists)


type Error = String
type Names = Array String

names :: TaskE Error Names
names =
  let
    checkArgs :: Effect (Either Error Names)
    checkArgs = do
      args <- (drop 2) <$> argv
      pure $
        if (length args > 0)
          then Right args
          else Left "you must enter at least one name"
  in
    newTask $ \callback -> do
      checkArgs >>= \args ->
        callback $ either (\e -> rej e) (\xs -> res xs) args
      pure $ nonCanceler

related :: String -> TaskE Error RelatedNames
related name =
    findArtist name >>= (\r -> relatedArtists r.id)


main :: Effect Unit
main = do
  log "Spotify!"
  void $ launchAff $
    names >>= traverse related #
    fork (\e -> Console.error $ "Error: " <> e) (\xs -> Console.logShow xs)
