module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Data.BooleanAlgebra (tt)
import Data.Monoid (class Monoid, mempty)

newtype Sum a = Sum a
instance showSum :: Show a => Show (Sum a) where
  show (Sum x) = "(Sum " <> show x <> ")"
instance semigroupSum :: Semiring a => Semigroup (Sum a) where
  append (Sum a) (Sum b) = Sum (a + b)
instance monoidSum :: Semiring a => Monoid (Sum a) where
  mempty = Sum zero


newtype All a = All a
instance showAll :: Show a => Show (All a) where
  show (All x) = "(All " <> show x <> ")"
instance semigroupAll :: BooleanAlgebra a => Semigroup (All a) where
  append (All a) (All b) = All (a && b)
instance monoidAll :: BooleanAlgebra a => Monoid (All a) where
  mempty = All tt


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  -- semigroups are concatable and associative
  log $ "alex"
  logShow $ (Sum 1) <> (Sum 2) <> mempty
  logShow $ (All true) <> (All false) <> mempty
  logShow $ (All true) <> (All true) <> mempty
