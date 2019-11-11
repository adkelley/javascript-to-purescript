module Main where

import Prelude

import Control.Monad.Cont.Trans (ContT(..), lift, runContT)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Array (concat, difference, drop, length, nubEq)
import Data.Either (Either(..), either)
import Data.Traversable (traverse)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Effect.Console (error, log, logShow)
import Node.Process (argv)
import Spotify (findArtist, relatedArtists)
import Types (Async, Error, ArtistNames, IO)


artistNames :: ExceptT Error Async ArtistNames
artistNames = ExceptT $ ContT $ \k -> do
  args <- (drop 2) <$> argv
  k $ if (length args > 1)
        then Right args
        else Left "Error: You must enter at least two artists"


main :: IO
main = do
  log "Spotify!"
  async do
    related <- runExceptT $ artistNames >>= traverse (\x -> findArtist x >>= relatedArtists)
    lift $ either (\e -> error e) (\x -> logShow $ mkTuple $ concat x) $ related
  where
    async :: Async Unit -> IO
    async = flip runContT pure

    inCommon :: Array String -> Array String
    inCommon related = nubEq $ difference related $ nubEq related

    mkTuple :: Array String -> Tuple Int (Array String)
    mkTuple related =
      (length related) /\ (inCommon related)
