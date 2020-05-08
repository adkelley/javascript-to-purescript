module Test.Main where

import Prelude

import Data.Eq (class Eq1)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), uncurry)
import Data.Unfoldable as U
import Data.Unfoldable1 as U1
import Effect (Effect)
import Effect.Console (log, logShow)
import Test.Assert (assert)

data NonEmpty f a = NonEmpty a (f a)

derive instance eqNonEmpty :: (Eq1 f, Eq a) => Eq (NonEmpty f a)

instance unfoldable1NonEmpty :: U.Unfoldable f => U1.Unfoldable1 (NonEmpty f) where
  unfoldr1 f = uncurry NonEmpty <<< map (U.unfoldr $ map f) <<< f

collatz :: Int -> Array Int
collatz = U.unfoldr step
  where
  step 1 = Nothing
  step n =
    Just $
      Tuple n $
        if n `mod` 2 == 0
        then n / 2
        else n * 3 + 1

main :: Effect Unit
main = do
  log "Collatz 1000"
  logShow $ collatz 1000

  log "Test none"
  assert $ U.none == ([] :: Array Unit)

  log "Test singleton"
  assert $ U.singleton unit == [unit]
  assert $ U1.singleton unit == NonEmpty unit []

  log "Test replicate"
  assert $ U.replicate 0 "foo" == []
  assert $ U.replicate 3 "foo" == ["foo", "foo", "foo"]
  assert $ U1.replicate1 0 "foo" == NonEmpty "foo" []
  assert $ U1.replicate1 3 "foo" == NonEmpty "foo" ["foo", "foo"]

  log "Test replicateA"
  assert $ U.replicateA 3 [1,2] == [
    [1,1,1],[1,1,2], [1,2,1],[1,2,2],
    [2,1,1],[2,1,2], [2,2,1],[2,2,2]
  ]

  log "Test range"
  assert $ U1.range 1 0 == [1, 0]
  assert $ U1.range 0 0 == [0]
  assert $ U1.range 0 2 == [0, 1, 2]
  assert $ U1.range 1 0 == NonEmpty 1 [0]
  assert $ U1.range 0 0 == NonEmpty 0 []
  assert $ U1.range 0 2 == NonEmpty 0 [1, 2]

  log "Test Maybe.toUnfoldable"
  assert $ U.fromMaybe (Just "a") == ["a"]
  assert $ U.fromMaybe (Nothing :: Maybe String) == []

  log "All done!"
