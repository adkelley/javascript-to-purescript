module Main where

import Prelude

import Control.Monad.Cont.Trans (lift, runContT)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Array (drop, length)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (error, log)
import Node.Process (argv)
import Spotify (findArtist, relatedArtists)
import Types (Async, Error, ArtistNames, IO)


artistNames :: ExceptT Error Effect ArtistNames
artistNames = ExceptT $ do
  args <- (drop 2) <$> argv
  pure $
    if (length args > 0)
      then Right args
      else Left "Error: You must enter at least one artist"


processNames :: ArtistNames -> IO
processNames names =
  async do
    related <- runExceptT $ traverse (\x -> findArtist x >>= relatedArtists) names
    lift $ log $ (either (\e -> show e) (\x -> show x)) related
  where
    async :: Async Unit -> IO
    async = flip runContT pure


main :: IO
main = do
  log "Spotify!"
  names <- runExceptT artistNames
  case names of
    Left e -> error e
    Right xs -> processNames xs
