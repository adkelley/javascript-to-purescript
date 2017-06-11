module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Either (Either(..), either)
import Data.Foreign (Foreign, isNull, isUndefined, toForeign, unsafeFromForeign)
import Data.Maybe (Maybe(..), fromJust, isNothing)
import Partial.Unsafe (unsafePartial)

foreign import null :: Foreign

type Address =
 { street :: Maybe String
 , city :: Maybe String
 , zip :: Maybe String
 }

type User =
  { name :: String
  , address :: Maybe Address
  , premium :: Boolean
  , preferences :: Maybe String
  }

fromNothing :: forall a. Maybe a -> Either (Maybe a) (Maybe a)
fromNothing value =
  if (isNothing value)
   then Left value
   else Right value

chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f  = either (\e -> Left e) (\x -> (f x))

fromNullable :: Foreign -> Either Foreign Foreign
fromNullable value =
  if (isNull value || isUndefined value)
   then Left value
   else Right value

-- Example 1
openSite :: Foreign -> String
openSite =
  fromNullable >>>
  either
    (\_ -> "showLogin")
    (\user -> "renderPage: " <> (unsafeFromForeign user :: String))

-- Example 2
defaultPrefs :: String
defaultPrefs = "defaultPrefs"

getPrefs :: User -> String
getPrefs =
  isPremium >>>
  map (_.preferences) >>>
  either
    (\_ -> defaultPrefs)
    (\prefs -> "loadPrefs: " <> (unsafePartial $ fromJust prefs))
  where
    isPremium :: User -> Either String User
    isPremium user =
      if (user.premium )
        then Right user
        else Left "not premimum"

-- Example 3
-- streetName :: Maybe Address -> String
-- streetName address =
--   fromNothing address #
--   chain (\address -> fromNothing address.street) #
--   either (\_ -> "no street") (\name -> (unsafePartial $ fromJust name))
--
-- streetName :: Address -> String
-- streetName address =
--   fromNothing address.street #
--   chain (\street -> fromNothing street) #
--   either (\_ -> "no street") (\name -> (unsafePartial $ fromJust name))


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "A collection of Either examples"

  log "Example 1"
  log $ openSite $ toForeign "Fred Flinstone"
  log $ openSite null

  let address1 = { street: Just "main street", city: "any city", zip: "zip"}
  let user1 = { name: "fred", address: Nothing, premium: true, preferences: Just "premium prefs" }
  let user2 = { name: "ethel", address: Nothing, premium: false, preferences: Nothing }
  log "Example 2"
  log $ getPrefs user1
  log $ getPrefs user2

  log "Example 3"
  log "Example 4"
  log "Example 5"
  log "Example 6"
  log "Game Over"
