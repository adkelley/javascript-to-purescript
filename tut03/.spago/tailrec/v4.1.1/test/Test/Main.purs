module Test.Main where

import Prelude

import Control.Monad.Rec.Class (Step(..), tailRec, tailRecM, tailRecM2, untilJust, whileJust)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Ref as Ref
import Test.Assert (assertEqual')

-- | Compute the nth triangle number
triangle :: Int -> Effect Int
triangle = tailRecM2 f 0
  where
  f acc 0 = pure (Done acc)
  f acc n = do
    log $ "Accumulator: " <> show acc
    pure (Loop { a: acc + n, b: n - 1 })

loop :: Int -> Effect Unit
loop n = tailRecM go n
  where
  go 0 = do
    log "Done!"
    pure (Done unit)
  go n' = pure (Loop (n' - 1))

loopFunction :: Int -> ({result :: Int, step :: Int} -> Int)
loopFunction = tailRecM go
  where
  go 0 = Done <$> \e -> e.result
  go n = Loop <$> \e -> n - e.step

mutual :: Int -> Boolean
mutual = tailRec go <<< Left
  where
  go (Left n) = even n
  go (Right n) = odd n

  even 0 = Done true
  even n = Loop (Right (n - 1))

  odd 0 = Done false
  odd n = Loop (Left (n - 1))

main :: Effect Unit
main = do
  test "triangle" 55 do
    triangle 10
  
  test "mutual" false do
    pure $ mutual 1000001

  test "loop" unit do
    loop 1000000

  test "loopFunction" 100 do
    pure $ loopFunction 10000000 ({result:100, step:1})
  
  test "whileJust" {acc: [1,2,3,4,5,6,7,8,9], res: 10} do
    ref <- Ref.new 0
    acc <- whileJust do
      st <- Ref.modify (_ + 1) ref
      pure $ if st < 10 then Just [st] else Nothing
    res <- Ref.read ref
    pure {res, acc}
  
  test "untilJust" 128 do
    ref <- Ref.new 1
    untilJust do
      st <- Ref.modify (_ * 2) ref
      pure $ if st > 89 then Just st else Nothing

  where
    test :: forall a. Show a => Eq a => String -> a -> Effect a -> Effect Unit
    test name expected compute = do
      log $ "START: " <> name
      actual <- compute
      assertEqual' "loopRes" {actual, expected}
