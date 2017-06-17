module Example1 (openSite) where

import Prelude

import Data.Either (Either(..), either)
import Data.Foreign (Foreign, isNull, isUndefined)
import Data.User (getName)

fromNullable :: Foreign -> Either Foreign Foreign
fromNullable value =
  if (isNull value || isUndefined value)
   then Left value
   else Right value

openSite :: Foreign -> String
openSite =
  fromNullable >>>
  either
    (\_ -> "showLogin()")
    (\user -> "renderPage(" <> (getName user) <> ")")
