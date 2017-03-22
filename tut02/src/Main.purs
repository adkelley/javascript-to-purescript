module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Replacement(..), Pattern(..), replace)
import Data.Box (Box(..), fold)

foreign import parseFloatImpl ::
  Fn3 (Number -> Maybe Number) (Maybe Number) String (Maybe Number)

safeParseFloat :: String -> Number
safeParseFloat str =
  runFn3 parseFloatImpl Just Nothing str #
  fromMaybe 0.0

-- | const moneyToFloat = str =>
-- | parseFloat(str.replace(/\$/g, ''))
moneyToFloat :: String -> Box Number
moneyToFloat str =
  Box str #
  map (replace (Pattern "$") (Replacement "")) #
  map (\replaced -> safeParseFloat replaced)


-- | const percentToFloat = str => {
-- | const replaced = str.replace(/\%/g, '')
-- | const number = parseFloat(replaced)
-- | return number * 0.01
-- | }
percentToFloat :: String -> Box Number
percentToFloat str =
  Box str #
  map (replace (Pattern "%") (Replacement "")) #
  map (\replaced -> safeParseFloat replaced) #
  map (_ * 0.01)

applyDiscount :: String -> String -> Number
applyDiscount price discount =
  moneyToFloat price #
  fold (\cost -> percentToFloat discount #
    fold (\savings -> cost - cost * savings))

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Refactor imperative code to a single composed expression using Box"
  logShow $ applyDiscount "$5.00" "20%"
