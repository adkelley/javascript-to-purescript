module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Either (Either(..))
import Data.List (List(..), filter, (:))
import Data.String.Regex (Regex, parseFlags, regex, replace)
import Partial.Unsafe (unsafePartial)
import Prelude (Unit, add, bind, map, mod, ($), (/=))

inc :: Int -> Int
inc = add 1

modulo :: Int -> Int -> Int
modulo dvr dvd = dvd `mod` dvr

isOdd :: Int -> Int
isOdd = modulo 2

getAllOdds :: List Int -> List Int
getAllOdds = filter (\x -> isOdd x /= 0)

regexString :: Regex
regexString =
  unsafePartial
    case (regex "[aeiou]" (parseFlags "ig")) of
      Right r -> r

censor :: String -> String
censor = replace regexString "*"

censorAll :: Array String -> Array String
censorAll = map censor

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Build curried functions"
  logShow $ inc 2
  logShow $ isOdd 2
  logShow $ isOdd 21
  logShow $ getAllOdds (1 : 2 : 3 : 4 : Nil)
  log $ censor "hello world"
  logShow $ censorAll ["hello", "world"]
