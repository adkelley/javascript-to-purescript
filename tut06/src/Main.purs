module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
-- see comment about null in main
--import Data.Array (null)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))

-- Create types with Semigroups
newtype Sum a = Sum a
instance showSum :: Show a => Show (Sum a) where
  show (Sum x) = "(Sum " <> show x <> ")"
instance semigroupSum :: Semiring a => Semigroup (Sum a) where
  append (Sum a) (Sum b) = Sum (a + b)
derive newtype instance eqSum :: Eq a => Eq (Sum a)

newtype All a = All a
instance showAll :: Show a => Show (All a) where
  show (All x) = "(All " <> show x <> ")"
instance semigroupAll :: BooleanAlgebra a => Semigroup (All a) where
  append (All a) (All b) = All (a && b)
derive instance eqAll :: Eq a => Eq (All a)

newtype First a = First a
instance showFirst :: Show a => Show (First a) where
  show (First x) = "(First " <> show x <> ")"
instance semigroupFirst :: Semigroup (First a) where
  append (First a) _ = (First a)
derive instance eqFirst :: Eq a => Eq (First a)


main :: Effect Unit
main = do
  log "Create types with Semigroups"
  -- semigroups are concatable and associative
  log "String and arrays:"
  log $ ("a" <> "b") <> "c"
  log $ "a" <> ("b" <> "c")
  logShow $  [1, 2] <> ([3, 4] <> [5, 6])
  logShow $ ([1, 2] <> [3, 4]) <> [5, 6]

  log "\nIntegers:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3  -- (Sum 6)
  log "Associativity law:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3 == Sum 1 <> (Sum 2 <> Sum 3)  -- true

  log "\nBooleans:"
  logShow $ All true <> All false -- (All false)
  log "Associativity law:"
  logShow $ (All true <> All true) <> All true == All true <> (All true <> All true) -- true

  log "\nFirst"
  logShow $ First "a" <> First "b" <> First "c"  -- (First "a")
  log "Associativity law:"
  logShow $ (First "a" <> First "b") <> First "c" == First "a" <> (First "b" <> First "c") -- true
  -- This won't compile because First is not a monoid (See tutorial 8)
  --logShow $ (First null) <> (First [1])
  -- This does compile
  logShow $ (First [1]) <> (First [2])

  log "\nPureScript equilivents from Data.Monoid.X"
  log "Additive == Sum"
  logShow $ Additive 1 <> Additive 2  -- (Addivitive 3)
  logShow $ Additive 1.0 <> Additive 2.0  -- (Addivive 3.0)
  log "Conj == All"
  logShow $ Conj true <> Conj false  -- (Conj false)
  logShow $ Conj true <> (Conj true <> Conj true)  -- (Conj true)
