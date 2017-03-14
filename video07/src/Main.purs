module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
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

-- Account (left of the equals sign) is a data constructor
-- Account (right of the equals sign) is a type constructor
data Account = Account
  { name    :: First String
  , isPaid  :: All Boolean
  , points  :: Sum Int
  , friends :: Array String
  }

showAccount :: Account -> String
showAccount
  (Account { name, isPaid, points, friends }) =
  "{ name: "  <> show name    <> ",\n  " <>
  "isPaid: "  <> show isPaid  <> ",\n  " <>
  "points: "  <> show points  <> ",\n  " <>
  "friends: " <> show friends <> "  }"

concatAccount :: Account -> Account -> Account
concatAccount
  (Account { name: a1, isPaid: b1, points: c1, friends: d1 })
  (Account { name: a2, isPaid: b2, points: c2, friends: d2 }) =
  (Account { name: a1 <> a2, isPaid: b1 <> b2, points: c1 <> c2, friends: d1 <> d2 })

makeAccount :: (First String) -> (All Boolean) -> (Sum Int) -> (Array String) -> Account
makeAccount name isPaid points friends = (Account { name, isPaid, points, friends })

acct1 :: Account
acct1 = makeAccount (First "Alex") (All true) (Sum 10) ["Franklin"]

acct2 :: Account
acct2 = makeAccount (First "Alex") (All false) (Sum 2) ["Gatsby"]

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  -- semigroups are concatable and associative
  log $ showAccount $ acct1 `concatAccount` acct2
