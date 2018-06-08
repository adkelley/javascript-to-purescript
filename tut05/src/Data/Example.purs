module Data.Example
  ( getPreviewPath
  , getCurrentExample
  , getDefaultPreview
  , getDbUrl
  ) where

import Foreign (Foreign)

foreign import previewPath :: Foreign -> Foreign
foreign import currentExample :: Foreign
foreign import dbUrl :: Foreign -> Foreign
foreign import defaultPreview :: Foreign

getPreviewPath :: Foreign -> Foreign
getPreviewPath = previewPath

getCurrentExample :: Foreign
getCurrentExample = currentExample

getDbUrl :: Foreign -> Foreign
getDbUrl = dbUrl

getDefaultPreview :: Foreign
getDefaultPreview = defaultPreview
