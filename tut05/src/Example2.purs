module Example2 (getPrefs) where

import Prelude

import Data.Either (either)
import Foreign (Foreign)
import Data.Utils (toEither)
import Data.User (getPremium, getPreferences, defaultPrefs)


getPrefs :: Foreign -> String
getPrefs user =
  toEither (getPremium user) "not premium" user #
  map getPreferences >>>
  either (\_ -> defaultPrefs) \prefs -> "loadPrefs " <> prefs
