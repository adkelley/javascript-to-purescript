module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Char (fromCharCode)
import Data.Int (fromString)
import Data.Lazy (Lazy, defer, force)
import Data.Maybe (fromMaybe)
import Data.String (trim, toLower)
import Unsafe.Coerce (unsafeCoerce)

lazyBox :: forall a. a -> Lazy a
lazyBox a = defer (\_ -> a)

nextCharForNumberString :: String -> Lazy String
nextCharForNumberString str = do
  lazyBox str #
  map trim #
  map (\s -> fromMaybe 0 $ fromString s) #
  map (\i -> i + 1) #
  map (\i -> fromCharCode i) #
  map (\c -> toLower $ unsafeCoerce c :: String)

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Delay Evaluation with LazyBox"
  log "The evaluation of 'nextCharForNumberString' is deferred . . ."
  let lazyFn = nextCharForNumberString "     64   "
  logShow lazyFn
  log "until we run the 'force' function which acts as our fold: "
  log $ force lazyFn
