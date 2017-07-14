module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
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


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Create types with Semigroups"
  -- semigroups are concatable and associative
  log "String and arrays:"
  log $ ("a" <> "b") <> "c"
  log $ "a" <> ("b" <> "c")
  logShow $  [1, 2] <> ([3, 4] <> [5, 6])
  logShow $ ([1, 2] <> [3, 4]) <> [5, 6]

  log "\nIntegers:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3
  log "Associativity law:"
  logShow $ (Sum 1 <> Sum 2) <> Sum 3 == Sum 1 <> (Sum 2 <> Sum 3)

  log "\nBooleans:"
  logShow $ append (All true) (All false)
  log "Associativity law:"
  logShow $ ((All true) <> (All true)) <> (All true) == (All true) <> ((All true) <> (All true))

  log "\nFirst"
  logShow $ (First "blah") <> ((First "icecream") <> (First "meta-programming"))
  log "Associativity law:"
  logShow $ ((First "blah") <> (First "icecream")) <> (First "meta-programming") == (First "blah") <> ((First "icecream") <> (First "meta-programming"))

  log "\nPureScript equilivents from Data.Monoid.X"
  log "Additive == Sum"
  logShow $ Additive 1 <> Additive 2
  logShow $ Additive 1.0 <> Additive 2.0
  log "Conj == All"
  logShow $ append (Conj true) (Conj false)
  logShow $ (Conj true) <> ((Conj true) <> (Conj true))
