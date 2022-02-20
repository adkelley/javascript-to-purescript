module Main where

import Prelude

import Control.Comonad (class Comonad, class Extend, extract)
import Data.Char (fromCharCode)
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Data.String (toLower, trim)
import Data.String.CodeUnits (singleton)
import Effect (Effect)
import Effect.Console (log)

-- Javascript - const Box = x => ({})
newtype Box a = Box a

-- Javascript - map: f => (f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)

-- Javascript - fold: f => f(x)
instance extendBox :: Extend Box where
  extend f m = Box (f m)

instance comonadBox :: Comonad Box where
  extract (Box x) = x

-- Javascript - inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"

-- Bundled parenthesis, all in one expression
-- This is suboptimal because its hard to follow
nextCharForNumberString' :: String -> String
nextCharForNumberString' str =
  singleton (fromMaybe ' ' (fromCharCode (fromMaybe 0 (fromString (trim (str))) + 1)))

-- Composition using oridinary functions.  This is simple, to read, write
-- use and reason about than bundled parenthesis.  See the ReadMe in Tutorial 2
-- for more information on this topic
nextCharForNumberString'' :: String -> String
nextCharForNumberString'' =
  trim
    >>> fromString
    >>> fromMaybe 0
    >>> (+) 1
    >>> fromCharCode
    >>> fromMaybe ' '
    >>> singleton

-- But when mixing categories (i.e., Box, Maybe), we'll often use
-- composition by putting s into a box and mapping over it
nextCharForNumberString :: String -> String
nextCharForNumberString str =
  Box str
    # map trim
    # map (\s -> fromMaybe 0 $ fromString s)
    # map (\i -> i + 1)
    # map (\i -> fromMaybe ' ' $ fromCharCode i)
    # map (\c -> toLower $ singleton c)
    # extract

main :: Effect Unit
main = do
  log "Create Linear Data Flow with Container Style Types (Box)."

  log "Bundled parenthesis approach, all in one expression is suboptimal."
  log $ nextCharForNumberString' "     64   "

  log "Composition using oridinary functions"
  log $ nextCharForNumberString'' "     64   "

  log "Let's borrow a trick from our friend array by putting string into a Box."
  log $ nextCharForNumberString "     64   "
