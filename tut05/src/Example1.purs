module Example1 (openSite) where

import Prelude

import Data.Either (either)
import Data.Foreign (Foreign, unsafeFromForeign)
import Data.User (getName)
import Data.Utils (chain, fromNullable)

openSite :: Foreign -> String
openSite =
  fromNullable >>>
  chain (\user -> fromNullable $ getName user) >>>
  map (\name -> unsafeFromForeign name :: String) >>>
  either
    (\_ -> "showLogin()")
    \name -> "renderPage(" <> name <> ")"
