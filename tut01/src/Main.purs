module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Char (fromCharCode)
import Data.Foldable (class Foldable, foldMap)
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Data.String (trim, toLower)
import Unsafe.Coerce (unsafeCoerce)

-- const Box = x =>
newtype Box a = Box a
-- map: f => (f(x))
instance functorBox :: Functor Box where
  map f (Box x) = Box (f x)
-- fold: f => f(x)
instance foldableBox :: Foldable Box where
  foldr f z (Box x) = f x z
  foldl f z (Box x) = f z x
  foldMap f (Box x) = f x
-- inspect: () => 'Box($(x))'
instance showBox :: Show a => Show (Box a) where
  show (Box a) = "Box(" <> show a <> ")"

nextCharForNumberString' :: String -> Char
nextCharForNumberString' str =
  fromCharCode(fromMaybe 0 (fromString(trim(str))) + 1)

nextCharForNumberString :: String -> String
nextCharForNumberString str = do
  (Box str) #
  map trim #
  map (\s -> fromMaybe 0 $ fromString s) #
  map (\i -> i + 1) #
  map (\i -> fromCharCode i) #
  foldMap (\c -> toLower $ unsafeCoerce c :: String)

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Create Linear Data Flow with Container Style Types (Box)"

  log "Bundled parenthesis approach"
  logShow $ nextCharForNumberString' "     64   "

  log "Let's borrow a trick from our friend array"
  log $ nextCharForNumberString "     64   "
