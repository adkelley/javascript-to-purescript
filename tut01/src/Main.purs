module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Char (fromCharCode, toLower)
import Data.Foldable (class Foldable, foldMap)
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Data.String (singleton, trim)

-- Javascript - const Box = x => ({})
newtype Box a = Box a
-- Javascript - map: f => (f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
-- Javascript - fold: f => f(x)
instance foldableBox :: Foldable Box where
  foldr f z (Box x) = f x z
  foldl f z (Box x) = f z x
  foldMap f (Box x) = f x
-- Javascript - inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"

-- Bundled parenthesis, all in one expression
-- This is suboptimal because its hard to follow
nextCharForNumberString' :: String -> String
nextCharForNumberString' str =
  singleton(fromCharCode(fromMaybe 0 (fromString(trim(str))) + 1))

-- A better approach is to use composition by putting
-- s into a box and mapping over it
nextCharForNumberString :: String -> String
nextCharForNumberString str =
  Box str #
  map trim #
  map (\s -> fromMaybe 0 $ fromString s) #
  map (\i -> i + 1) #
  map (\i -> fromCharCode i) #
  foldMap (\c -> singleton $ toLower c)

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Create Linear Data Flow with Container Style Types (Box)."

  log "Bundled parenthesis approach, all in one expression is suboptimal."
  log $ nextCharForNumberString' "     64   "

  log "Let's borrow a trick from our friend array by putting string into a Box."
  log $ nextCharForNumberString "     64   "
