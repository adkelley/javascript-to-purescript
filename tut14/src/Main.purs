module Main where

import Prelude

import Data.Bifunctor (bimap)
import Data.Box (Box(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (log, logShow)

foreign import toUpperCase :: String -> String
-- ignores that substr takes an optional length argument
foreign import substrImpl :: Int -> String -> String

-- | First law of Functors
-- | Composition: map f1 <<< map f2 == map (f1 <<< f2)
res1 :: Box String
res1 =
  Box "squirrels"
  # map (\str -> substrImpl 5 str)
  # map toUpperCase

res2 :: Box String
res2 =
  Box "Squirrels"
  # map (\str -> toUpperCase $ substrImpl 5 str)

-- | Second law of functors
-- | Identity: map identity = identity
res3 :: Box String
res3 =
  Box "crayons"
  # map identity

res4 :: Box String
res4 =
  identity (Box "crayons")

-- | Bifunctor examples

-- | First law of Functors
-- | Composition: bimap f1 g1 <<< bimap f2 g2 == bimap (f1 <<< f2) (g1 <<< g2)

res5 :: Box (Tuple String String)
res5 =
  Box $ Tuple "squirrels" "rabbits"
  # bimap (\str → substrImpl 5 str) (\str → substrImpl 5 str)
  # bimap toUpperCase toUpperCase

res6 :: Box (Tuple String String)
res6 =
  Box $ Tuple "squirrels" "rabbits"
  # bimap
      (\str -> toUpperCase $ substrImpl 5 str)
      (\str -> toUpperCase $ substrImpl 5 str)

-- | Second law of Functors
-- | Identity: bimap idenity identity == identity
res7 :: Box (Tuple String String)
res7 =
  Box $ Tuple "crayons" "markers"
  # bimap identity identity

res8 :: Box (Tuple String String)
res8 =
  identity $ Box $ Tuple "crayons" "markers"

-- | What happens when we apply a functor
-- | to a Tuple?
res9 :: Box (Tuple String String)
res9 =
  Box $ Tuple "crayons" "markers"
  # map  (\str -> toUpperCase $ substrImpl 5 str)

-- | ProFunctor example


main :: Effect Unit
main = do
  log "You've been using Functors"
  log "\nFunctor laws:"
  log "Composition:"
  logShow res1
  logShow res2
  log "Identity:"
  logShow res3
  logShow res4
  log "\nBiFunctor examples"
  log "Composition:"
  logShow res5
  logShow res6
  log "Identity:"
  logShow res7
  logShow res8
  log "\nApply functor to Tuple"
  logShow res9
