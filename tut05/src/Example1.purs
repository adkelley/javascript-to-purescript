module Example1 (openSite) where

import Prelude

import Data.Either (either)
import Foreign (Foreign)
import Data.Utils (fromNullable)

openSite :: Foreign -> String
openSite =
  fromNullable >>>
  either (\_ -> "showLogin") \_ -> "renderPage"
