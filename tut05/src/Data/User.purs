module Data.User ( getCurrentUser
                 , getPremium
                 , getPreferences
                 , defaultPrefs
                 , getName
                 , getAddress
                 , getStreet
                 , getStreetName
                 , returnNull) where

import Foreign (Foreign)

foreign import currentUser :: Foreign
foreign import null :: Foreign
foreign import premium :: Foreign -> Boolean
foreign import preferences :: Foreign -> String
foreign import name :: Foreign -> Foreign
foreign import address :: Foreign -> Foreign
foreign import street :: Foreign -> Foreign
foreign import streetName :: Foreign -> Foreign

getPreferences :: Foreign -> String
getPreferences = preferences

defaultPrefs :: String
defaultPrefs = "defaultPrefs"

getCurrentUser :: Foreign
getCurrentUser = currentUser

returnNull :: Foreign
returnNull = null

getPremium :: Foreign -> Boolean
getPremium = premium

getName :: Foreign -> Foreign
getName = name

getAddress :: Foreign -> Foreign
getAddress = address

getStreet :: Foreign -> Foreign
getStreet = street

getStreetName :: Foreign -> Foreign
getStreetName = streetName
