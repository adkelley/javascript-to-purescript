module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res, taskOf)
import Data.Array (drop, length)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (error, logShow) as Console
import Effect.Console (log)
import Node.Process (argv)

type Error = String
type Artist = String
type Names = Array String
type RelatedArtists = Array String
type Id = Int

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

findArtist :: String -> TaskE Error Artist
findArtist name = taskOf name

relatedArtists :: Id -> TaskE Error RelatedArtists
relatedArtists id = taskOf ["Oasis", "Blur"]

artistId :: Artist -> TaskE Error Int
artistId _ = taskOf 10

related :: String -> TaskE Error RelatedArtists
related name = relatedArtists =<< artistId =<< findArtist name

main :: Effect Unit
main = do
  log "Spotify!"
  void $ launchAff $
    names >>= traverse related #
    fork (\e -> Console.error $ "Error: " <> e) (\xs -> Console.logShow xs)
