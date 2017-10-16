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
import Data.Function.Uncurried (Fn2, mkFn2, runFn2)

nextCharForNumberString :: String -> Lazy String
nextCharForNumberString str = do
  defer (\_ -> str) #
  map trim #
  map (\s ->fromMaybe 0 $ fromString s) #
  map (_ + 1) #
  map (\i -> fromCharCode i) #
  map (\c -> toLower $ unsafeCoerce c :: String)

add2 :: Fn2 Int Int Int
add2 = mkFn2 \x y -> x + y


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Delay Evaluation with LazyBox"
  log "The evaluation of 'nextCharForNumberString' is deferred . . ."
  let lazyVal = nextCharForNumberString "     64   "
  logShow lazyVal
  log "until we run the 'force' function which acts as our fold: "
  log $ force lazyVal
  log "Use Data.Function.Uncurried for functions with critical performance"
  logShow $ runFn2 add2 2 2
