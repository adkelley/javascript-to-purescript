module Main where

import Prelude
import Control.Comonad (extract)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.Box (Box(..))
import Data.String (Replacement(..), Pattern(..), replace)

-- We use an unsafe prefix for parseFloat, because JS parseFloat
-- may return NaN.  We deal with this case by returning 0.0 (see Main.js)
foreign import unsafeParseFloat :: String -> Number

moneyToFloat :: String -> Box Number
moneyToFloat str =
  Box str #
  map (replace (Pattern "$") (Replacement "")) #
  map (\replaced -> unsafeParseFloat replaced)

-- No different than moneyToFloat with the exception of showing that
-- we can always start immediately with a `Box` of `str.replace( )`
-- It comes down to your preference for readability and performance
percentToFloat :: String -> Box Number
percentToFloat str =
  Box (replace (Pattern "%") (Replacement "") str) #
  map (\replaced -> unsafeParseFloat replaced) #
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

-- Bonus Example: For those who are familar with Monads,  Besides using oridinary
-- functions, these bind operations (>>=) are perhaps the more canonical approach
-- for solving applyDiscount. We'll cover them in a later tutorial
applyDiscount' :: String -> String -> Number
applyDiscount' price discount = extract $
  (moneyToFloat price) >>=
    (\cost -> (percentToFloat discount) >>=
      (\savings -> pure $ cost - cost * savings))


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Refactor imperative code to a single composed expression using Box"
  log "Using extract to remove x from the Box before applying the final expression"
  logShow $ applyDiscount "$5.00" "20%"
  log "Oh god - Monad bind operations already!  Only if you want them"
  logShow $ applyDiscount' "$5.00" "20%"
