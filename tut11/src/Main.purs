module Main where

import Prelude

import Data.Char (fromCharCode)
import Data.Function.Uncurried (Fn2, mkFn2, runFn2)
import Data.Int (fromString)
import Data.Lazy (Lazy, defer, force)
import Data.Maybe (fromMaybe)
import Data.String (trim, toLower)
import Data.String.CodeUnits (singleton)
import Effect (Effect)
import Effect.Console (log, logShow)

nextCharForNumberString :: String -> Lazy String
nextCharForNumberString str =
  defer (\_ -> str) #
  map trim #
  map (\s ->fromMaybe 0 $ fromString s) #
  map (_ + 1) #
  map (\i -> fromMaybe ' ' $ fromCharCode i) #
  map (\c -> toLower $ singleton c)

add2 :: Fn2 Int Int Int
add2 = mkFn2 \x y -> x + y


main :: Effect Unit
main = do
  log "Delay Evaluation with LazyBox"
  log "The evaluation of 'nextCharForNumberString' is deferred . . ."
  let lazyVal = nextCharForNumberString "     64   "
  logShow lazyVal
  log "until we run the 'force' function which acts as our fold: "
  log $ force lazyVal
  log "Use Data.Function.Uncurried for functions with critical performance"
  logShow $ runFn2 add2 2 2
