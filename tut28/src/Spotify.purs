module Spotify (RelatedNames, findArtist, relatedArtists) where

import Prelude

import Control.Monad.Task (TaskE, newTask, rej, res, taskOf, taskRejected)
import Data.Array (head)
import Data.Either (Either(..), either)
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (logShow)
import Node.HTTP.Client (Request, Response, requestAsStream, requestFromURI, responseAsStream, responseHeaders, statusMessage)
import Node.Stream (Writable, end, pipe)
import Secret (accessToken)
import Simple.JSON (readJSON)

foreign import stdout :: forall r. Writable r

type Error = String

type Id = {id :: String}

type Artists =
  { artists :: {items :: Array Id}
  }

type RelatedNames = Array String

type RelatedArtists =
  { artists :: Array {name :: String} }

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

logResponse :: Response -> Effect Unit
logResponse res = void do
  logShow $ statusMessage res
  let responseStream = responseAsStream res
  pipe responseStream stdout

eitherToTask :: forall a. Either Error a -> TaskE Error a
eitherToTask = either (\e -> taskRejected e) (\a -> taskOf a)

maybeToEither :: forall a. Maybe a -> Either Error a
maybeToEither (Just a) = Right a
maybeToEither Nothing = Left ""

-- httpGet :: String -> Effect Unit
-- httpGet name = do
--     req <- requestFromURI (url name) logResponse
--     end (requestAsStream req) (pure unit)
httpGetSearch :: String -> TaskE Error Body
httpGetSearch url =
  taskOf """
    {"artists": {"items": [{"imageURL": "jfsdjfkdfj", "id": "1u3g8PeUxNzaQmolXTwZRL"}]}}
  """

parseJSONSearch :: String -> Either Error (Artists)
parseJSONSearch body =
   case readJSON body of
     Right (r :: Artists) -> Right r
     Left e -> Left "Artists not found"

getJSONSearch :: String -> TaskE Error Artists
getJSONSearch url =
  parseJSONSearch <$> httpGetSearch url >>= eitherToTask

findArtist :: String -> TaskE Error Id
findArtist name =
  (\r -> maybeToEither $ head r.artists.items) <$> getJSONSearch (artistURL name) >>= eitherToTask


httpGetRelated :: String -> TaskE Error Body
httpGetRelated url =
  taskOf """
    {"artists": [{"name": "Fiona Hill"}, {"name": "Imogen Heap"}]}
  """

parseJSONRelated :: String -> Either Error RelatedArtists
parseJSONRelated body =
   case readJSON body of
     Right (r :: RelatedArtists) -> Right r
     Left e -> Left "Related Artists not found"

getJSONRelated :: String -> TaskE Error RelatedArtists
getJSONRelated url =
  parseJSONRelated <$> httpGetRelated url >>= eitherToTask

relatedArtists :: String -> TaskE Error RelatedNames
relatedArtists id =
   (\r -> _.name <$> r.artists) <$> getJSONRelated (relatedArtistsURL id)
