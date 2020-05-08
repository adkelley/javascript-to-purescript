module Test.Main where

import Prelude

import Control.Monad.Gen as Gen
import Control.Monad.Gen.Common as GenC
import Control.Monad.Rec.Class (class MonadRec, tailRecM)
import Data.Bifunctor (bimap)
import Data.Int as Int
import Data.NonEmpty (NonEmpty, (:|))
import Data.Tuple (Tuple(..), snd)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Random.LCG as LCG
import Test.Assert (assertEqual)

main :: Effect Unit
main = do

  seed ← LCG.randomSeed

  runTestGen seed do

    log $ show seed

    log "`unfoldable` should not loop on negative size"
    nil :: Array Unit ← Gen.resize (const (-1)) $ Gen.unfoldable (pure unit)
    liftEffect $ assertEqual { actual: nil, expected: [] }

    log "`genNonEmpty` should not reduce the remainder size below zero"
    one :: NonEmpty Array Int ← Gen.resize (const 0) $ GenC.genNonEmpty (Gen.sized pure)
    liftEffect $ assertEqual { actual: one, expected: 0 :| [] }

--------------------------------------------------------------------------------

type GenState = Tuple LCG.Seed Int

newtype TestGen a = TestGen (GenState -> Effect (Tuple GenState a))

derive instance functorTestGen :: Functor TestGen

instance applyTestGen :: Apply TestGen where
  apply = ap

instance applicativeTestGen :: Applicative TestGen where
  pure a = TestGen (pure <<< flip Tuple a)

instance bindTestGen :: Bind TestGen where
  bind gen f =
    TestGen \s ->
      unTestGen gen s >>= \(Tuple s' v) ->
        unTestGen (f v) s'

instance monadTestGen :: Monad TestGen

instance monadRecTestGen :: MonadRec TestGen where
  tailRecM f a = TestGen (tailRecM go <<< flip Tuple a)
    where
      go (Tuple s a') =
        unTestGen (f a') s >>= \(Tuple s' m) ->
          pure $ bimap (Tuple s') (Tuple s') m

instance monadGenTestGen :: Gen.MonadGen TestGen where
  chooseInt a b = Int.round <$> Gen.chooseFloat (Int.toNumber a) (Int.toNumber b)
  chooseFloat a b = uniform <#> \n -> a + (b - a) * n
  chooseBool = (_ < 0.5) <$> uniform
  resize f (TestGen k) = TestGen \(Tuple seed size) -> k (Tuple seed (f size))
  sized f = TestGen \s -> case f (snd s) of TestGen k -> k s

instance monageEffectTestGen :: MonadEffect TestGen where
  liftEffect a = TestGen \st -> Tuple st <$> a

lcgStep :: TestGen Int
lcgStep =
  TestGen \(Tuple seed size) ->
    pure $ Tuple (Tuple (LCG.lcgNext seed) size) (LCG.unSeed seed)

uniform :: TestGen Number
uniform = lcgStep <#> (\n -> Int.toNumber n / Int.toNumber LCG.lcgM)

unTestGen :: forall a. TestGen a -> GenState -> Effect (Tuple GenState a)
unTestGen (TestGen k) = k

runTestGen :: forall a. LCG.Seed -> TestGen a -> Effect a
runTestGen seed gen = snd <$> unTestGen gen (Tuple seed 5)
