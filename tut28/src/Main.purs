module Main where

import Prelude

import Control.Monad.Cont.Trans (ContT(..), lift, runContT)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Array (drop, length)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Effect.Console (error, log, logShow)
import Node.Process (argv)
import Spotify (findArtist, relatedArtists)
import Types (Async, Error, ArtistNames, IO)


artistNames :: ExceptT Error Async ArtistNames
artistNames = ExceptT $ ContT $
  \k -> do
    args <- (drop 2) <$> argv
    k $ if (length args > 0)
          then Right args
          else Left "Error: You must enter at least one artist"


main :: IO
main = do
  log "Spotify!"
  async do
    related <- runExceptT $ artistNames >>= traverse (\x -> findArtist x >>= relatedArtists)
    lift $ (either (\e -> error e) (\x -> logShow x)) related
  where
    async :: Async Unit -> IO
    async = flip runContT pure
