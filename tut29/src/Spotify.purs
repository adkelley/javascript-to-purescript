module Spotify (findArtist, relatedArtists) where

import Prelude

import Control.Monad.Except.Trans (ExceptT, mapExceptT)
import Data.Array (head)
import Data.Either (Either(..), either)
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))
import Network.HTTP.Client (get)
import Secret (accessToken)
import Simple.JSON (readJSON)
import Types (Async, Error, ArtistName, ArtistNames, Id)

type ArtistId = {id :: String}
type Artists =  { artists :: { items :: Array ArtistId }  }
type RelatedArtists = { artists :: Array {name :: String} }
type Body = String

path :: String
path = "https://api.spotify.com/v1/"

-- https://api.spotify.com/v1/search?q={name}&type=artist&access_token=${accessToken}
-- artists: {items []}
artistURL :: String -> String
artistURL name =
  foldl (<>) path ["search?q=", name, "&type=artist", accessToken]


-- https://api.spotify.com/v1/artists/{id}/related-artists?access_token={accessToken}
-- artists: {[name: "Flo Rita", name: "Taio Cruz"]}
relatedArtistsURL :: String -> String
relatedArtistsURL id =
  foldl (<>) path ["artists/", id, "/related-artists?", accessToken]


maybeToEither :: Maybe ArtistId -> Either Error Id
maybeToEither (Just r) = Right r.id
maybeToEither Nothing = Left "Error: no artist id"


parseArtists :: Async (Either Error Body) -> Async (Either Error Id)
parseArtists ares =
  map (either (\e -> Left e) (\x -> getId x)) ares
  where
    getId res =
      case readJSON res of
        Right (r :: Artists) -> maybeToEither $ head r.artists.items
        Left e -> Left "Error: improper JSON string"


findArtist :: ArtistName -> ExceptT Error Async Id
findArtist name =
  mapExceptT parseArtists $ get $ artistURL name


parseRelated :: Async (Either Error Body) -> Async (Either Error ArtistNames)
parseRelated ares =
  map (either (\e -> Left e) (\x -> getRelated x)) ares
  where
   getRelated res =
     case readJSON res of
       Right (rs :: RelatedArtists) -> Right $ (\r -> r.name) <$> rs.artists
       Left e -> Left "Error: related artists not found"


relatedArtists :: String -> ExceptT Error Async ArtistNames
relatedArtists id = do
  mapExceptT parseRelated $ get $ relatedArtistsURL id
