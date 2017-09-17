module Test.Main where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid (class Monoid, mempty)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Ord.Max (Max(..))
import Data.Ord.Min (Min(..))

import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)

theAssociativeProperty :: ∀ a m
                        . Eq m
                       => Show m
                       => Monoid m
                       => m -> m -> m
                       -> Aff a Unit
theAssociativeProperty a b c = Assert.equal ((a <> b) <> c) (a <> (b <> c))

neutralElement :: ∀ a m
                . Eq m
               => Show m
               => Monoid m
               => m
               -> Aff a Unit
neutralElement m = Assert.equal mempty m

toNothing :: ∀ a. Maybe a -> Maybe a
toNothing _ = Nothing

main :: forall e
      . Eff ( console :: CONSOLE, testOutput :: TESTOUTPUT, avar :: AVAR | e) Unit
main = runTest do
  suite "Additive" do
    test "Monoid Laws" do
      theAssociativeProperty (Additive 1) (Additive 2) (Additive 3)
      neutralElement (Additive 0)
    test "foldMap" do
      Assert.assert "foldMap Additive [1, 2, 3] should be 6" $
        foldMap Additive [1, 2, 3] == (Additive 6)
  suite "Conj" do
    test "Monoid Laws" do
      theAssociativeProperty (Conj true) (Conj true) (Conj true)
      neutralElement (Conj true)
    test "foldMap" do
      Assert.assert "foldMap Conj [true, true, false] should be false" $
        foldMap Conj [true, true, false] == (Conj false)
  suite "Disj" do
    test "Monoid Laws" do
      theAssociativeProperty (Disj true) (Disj true) (Disj true)
      neutralElement (Disj false)
    test "foldMap" do
      Assert.assert "foldMap Disj [true, true, false] should be true" $
        foldMap Disj [true, true, false] == (Disj true)
  suite "First" do
    test "Monoid Laws" do
      theAssociativeProperty (First (Just 1)) (First (Just 2)) (First (Just 3))
      -- trick the compiler into believing that we're not passing Nothing
      neutralElement (First $ toNothing (Just 1))
    test "foldMap" do
      Assert.assert "foldMap First [(Just true),(Just true),(Just false)] should be (First (Just true))" $
        foldMap First [Nothing, (Just true), Nothing] == First (Just true)
  suite "Max" do
    test "Monoid Laws" do
      theAssociativeProperty (Max 1) (Max 2) (Max 3)
      neutralElement (Max (negate 2147483648))
    test "foldMap" do
      Assert.assert "foldMap Max [1, 2, 3] should be (Max 3)" $
        foldMap Max [1, 2, 3] == Max 3
  suite "Min" do
    test "Monoid Laws" do
      theAssociativeProperty (Min 1) (Min 2) (Min 3)
      neutralElement (Min 2147483647)
    test "foldMap" do
      Assert.assert "foldMap Min [1, 2, 3] should be (Min 1)" $
        foldMap Min [1, 2, 3] == Min 1
