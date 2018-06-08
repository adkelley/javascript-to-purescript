module Example3 (streetName) where

import Prelude

import Data.Either (either)
import Data.User (getAddress, getStreet, getStreetName)
import Data.Utils (fromNullable)
import Foreign (Foreign, unsafeFromForeign)


-- | Look ma - no chains!
streetName :: Foreign -> String
streetName user =
  (fromNullable $ getAddress user) >>=
  (\address -> fromNullable $ getStreet address) >>=
  (\street -> fromNullable $ getStreetName street) >>>
  map (\name -> unsafeFromForeign name :: String) #
  either (\_ -> "no street") identity
