module Main where

import Prelude
-- import Control.Comonad (extract)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Box (Box(..))
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Replacement(..), Pattern(..), replace)

foreign import parseFloatImpl ::
  Fn3 (Number -> Maybe Number) (Maybe Number) String (Maybe Number)

safeParseFloat :: String -> Number
safeParseFloat str =
  runFn3 parseFloatImpl Just Nothing str #
  fromMaybe 0.0


moneyToFloat :: String -> Box Number
moneyToFloat str =
  Box str #
  map (replace (Pattern "$") (Replacement "")) #
  map (\replaced -> safeParseFloat replaced)


percentToFloat :: String -> Box Number
percentToFloat str =
  Box str #
  map (replace (Pattern "%") (Replacement "")) #
  map (\replaced -> safeParseFloat replaced) #
  map (_ * 0.01)

fold :: forall a b. (a -> b) -> Box a -> b
fold f (Box x) = f x

applyDiscount :: String -> String -> Number
applyDiscount price discount =
  moneyToFloat price #
  fold (\cost -> percentToFloat discount #
    fold (\savings -> cost - cost * savings))

-- applyDiscount :: String -> String -> Number
-- applyDiscount price discount = cost - cost * savings
--   where
--     cost = extract $ moneyToFloat price
--     savings = extract $ percentToFloat discount


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Refactor imperative code to a single composed expression using Box"
  logShow $ applyDiscount "$5.00" "20%"
