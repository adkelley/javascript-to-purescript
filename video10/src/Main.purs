
module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Data.Foldable (fold, foldMap)
import Data.Map (fromFoldable) as M
import Data.List (fromFoldable) as L
import Data.Monoid (class Monoid)
import Data.Tuple (Tuple(..))

newtype Sum a = Sum a
instance showSum :: Show a => Show (Sum a) where
  show (Sum x) = "(Sum " <> show x <> ")"
instance semigroupSum :: Semiring a => Semigroup (Sum a) where
  append (Sum a) (Sum b) = Sum (a + b)
instance monoidSum :: Semiring a => Monoid (Sum a) where
  mempty = Sum zero


main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  logShow $ fold [(Sum 1), (Sum 2), (Sum 3)]
  logShow $ fold $ M.fromFoldable [(Tuple "brian" (Sum 1)), (Tuple "sarah" (Sum 2))]
  logShow $ fold $ map Sum $ M.fromFoldable [(Tuple "brian" 1), (Tuple "sarah" 2)]
  logShow $ fold $ map Sum $ L.fromFoldable [1, 2, 3]
  logShow $ foldMap Sum $ M.fromFoldable [(Tuple "brian" 1), (Tuple "sarah" 2)]
  logShow $ foldMap Sum $ L.fromFoldable [1, 2, 3]
