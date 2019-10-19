module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res, taskOf, taskRejected)
import Data.Array (drop, length)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (launchAff, nonCanceler)
import Effect.Class.Console (error, log, logShow) as Console
import Effect.Console (log, logShow)
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
      args <- argv >>= \xs -> pure $ drop 2 xs
      pure $
        if (length args < 2)
          then Left "must input >= 2 names"
          else Right args
  in
    newTask $ \callback -> do
      checkArgs >>= \args ->
        callback $ either (\e -> rej e) (\xs -> res xs) args
      pure $ nonCanceler

findArtist :: String -> TaskE Error Artist
findArtist name = taskOf name

relatedArtists :: Id -> TaskE Error RelatedArtists
relatedArtists id = taskOf ["Alex", "Billy"]

artistId :: Artist -> TaskE Error Int
artistId artist = taskRejected "no id"

related :: String -> TaskE Error RelatedArtists
related name = findArtist name >>= artistId >>= relatedArtists

main :: Effect Unit
main = do
  log "Spotify!"
  void $ launchAff $
    names >>= traverse related #
    fork (\e -> Console.error $ "Error: " <> e) (\xs -> Console.logShow xs)
