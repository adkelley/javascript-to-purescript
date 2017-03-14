-- | Some partial helper functions.
module Partial 
  ( crash
  , crashWith
  ) where

-- | A partial function which crashes on any input with a default message.
crash :: forall a. Partial => a
crash = crashWith "Partial.crash: partial function"

-- | A partial function which crashes on any input with the specified message.
foreign import crashWith :: forall a. Partial => String -> a
