module Data.Example (getPreviewPath, getCurrentExample) where

import Data.Foreign (Foreign)

foreign import previewPath :: Foreign -> Foreign
foreign import currentExample :: Foreign

getPreviewPath :: Foreign -> Foreign
getPreviewPath = previewPath

getCurrentExample :: Foreign
getCurrentExample = currentExample
