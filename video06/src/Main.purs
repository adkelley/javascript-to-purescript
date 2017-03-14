module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Prelude

-- Create types with Semigroups
newtype Sum a = Sum a
instance showSum :: Show a => Show (Sum a) where
  show (Sum x) = "(Sum " <> show x <> ")"
instance semigroupSum :: Semiring a => Semigroup (Sum a) where
  append (Sum a) (Sum b) = Sum (a + b)


newtype All a = All a
instance showAll :: Show a => Show (All a) where
  show (All x) = "(All " <> show x <> ")"
instance semigroupAll :: BooleanAlgebra a => Semigroup (All a) where
  append (All a) (All b) = All (a && b)

newtype First a = First a
instance showFirst :: Show a => Show (First a) where
  show (First x) = "(First " <> show x <> ")"
instance semigroupFirst :: Semigroup (First a) where
  append (First a) _ = (First a)


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  log "Create types with Semigroups"
  -- semigroups are concatable and associative
  log $ ("a" <> "b") <> "c"
  log $ "a" <> ("b" <> "c")
  logShow $  [1, 2] <> ([3, 4] <> [5, 6])
  logShow $ ([1, 2] <> [3, 4]) <> [5, 6]
  logShow $ (Sum 1) <> (Sum 2)
  logShow $ (Sum 1.0) <> (Sum 2.0)
  logShow $ append (All true) (All false)
  logShow $ (All true) <> ((All true) <> (All true))
  logShow $ (First "blah") <> (First "icecream")
