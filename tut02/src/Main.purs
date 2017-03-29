module Main where

import Prelude
import Control.Comonad (extract)
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

-- Notice how we have cost captured in a closure here. We can continue on
-- capturing variables (i.e., discount) by just nesting in these closures.
-- We use extract to take them out of their Box before apply the expression
-- applyDiscount = cost - cost * savings
applyDiscount :: String -> String -> Number
applyDiscount price discount =
  (extract $ moneyToFloat price) #
  (\cost -> (extract $ percentToFloat discount)  #
    (\savings -> cost - cost * savings))

-- For those that like to think ahead, this monad bind operation
-- is perhaps the more canonical pattern for solving applyDiscount
applyDiscount' :: String -> String -> Number
applyDiscount' price discount = extract $
  (moneyToFloat price) >>=
    (\cost -> (percentToFloat discount) >>= 
      (\savings -> pure $ cost - cost * savings))


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Refactor imperative code to a single composed expression using Box"
  log "Using extract to remove x from the Box before apply the expression"
  logShow $ applyDiscount "$5.00" "20%"
  log "Oh god - Monads bind operations already!  Only if you want them"
  logShow $ applyDiscount' "$5.00" "20%"
