module Types (Async, IO, Error, Response, ArtistName, ArtistNames, Id) where

import Prelude (Unit)

import Control.Monad.Cont.Trans (ContT)
import Effect (Effect)

type Async = ContT Unit Effect
type Error = String
type Response = String
type ArtistName = String
type ArtistNames = Array ArtistName
type Id = String
type IO = Effect Unit
