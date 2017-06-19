module Example2 (getPrefs) where

import Prelude

import Data.Either (Either(..), either)
import Data.Foreign (Foreign)
import Data.User (getPremium, getPreferences, defaultPrefs)


isPremium :: Foreign -> Either String Foreign
isPremium user =
  if (getPremium user)
    then Right user
    else Left "not premium"

getPrefs :: Foreign -> String
getPrefs =
  isPremium >>>
  map getPreferences >>>
  either (\_ -> defaultPrefs) \prefs -> "loadPrefs(" <> prefs <> ")"
