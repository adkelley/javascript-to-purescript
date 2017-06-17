module Example3 (streetName) where

import Data.Either (either)
import Data.Foreign (Foreign)
import Data.User (getAddress, getStreet, getStreetName)
import Data.Utils (fromNullable, chain)
import Prelude


streetName :: Foreign -> String
streetName user =
  fromNullable (getAddress user) #
  chain (\address -> fromNullable $ getStreet address) #
  map (\street -> getStreetName street) #
  either (\_ -> "no street") (\name -> name)
