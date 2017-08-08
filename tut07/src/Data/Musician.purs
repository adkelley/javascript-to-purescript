module Data.Musician
  ( Person
  , Musician
  , makePerson
  , makeMusician
  , setGenre
  ) where

import Data.Maybe (Maybe)


type Person r =
  { firstName :: String
  , lastName  :: String
  , age       :: Maybe Int
  | r
  }

type Musician = Person ( genre :: String )

makePerson :: String -> String -> Maybe Int -> Person ()
makePerson = { firstName: _, lastName: _, age: _ }

makeMusician :: String -> String -> Maybe Int -> String -> Musician
makeMusician = { firstName: _, lastName: _, age: _ , genre: _ }

setGenre :: String -> Musician -> Musician
setGenre g m = m { genre = g }
