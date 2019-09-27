module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, taskOf, taskRejected)
import Data.Array (head, intercalate)
import Data.Box (Box(..))
import Data.Either (Either(..), either)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class.Console (error, log, logShow) as Console
import Effect.Console (log)

type Error = String

boxToEither :: forall b. Box b -> Either Error b
boxToEither (Box b) = Right b

-- Law of Natural Transformations
-- (a -> b) -> nt a -> nt b == nt $ (a -> b) -> f a -> f b

-- (a -> b) -> nt a -> nt b
res1 :: Either Error Int
res1 = (\x -> x * 2) <$> (boxToEither $ Box 100)

-- nt $ (a -> b) -> f a -> f b
res2 :: Either Error Int
res2 = boxToEither $ (\x -> x * 2) <$> Box 100

-- (a -> b) -> nt a -> nt b
res3 :: Array Int -> Maybe Int
res3 xs = map (\x -> x + 1) $ head xs

-- nt $ (a -> b) -> f a -> f b
res4 :: Array Int -> Maybe Int
res4 xs = head $ map (\x -> x + 1) xs


eitherToTask :: forall a. Either Error a -> TaskE Error a
eitherToTask = either (\e -> taskRejected e) (\a -> taskOf a)

main :: Effect Unit
main = do
  log "Tutorial 24: Principled type conversions with Natural Transformations"

  void $ launchAff $
    eitherToTask (Right "Nightingale") #
    fork (\e -> Console.error $ "Error: " <> e) (\s -> Console.log $ "Result: " <> s)

  void $ launchAff $
    eitherToTask (Left "errrrr") #
    fork (\e -> Console.error $ "Error: " <> e) (\s -> Console.log $ "Result: " <> s)

  void $ launchAff $
    Console.logShow $ boxToEither $ Box 100

  void $ launchAff $
    Console.log $ intercalate " == " $ show <$> [res1, res2]

  void $ launchAff $
    Console.log $ intercalate " == " $ show <$> [res3 [1, 2, 3], res4 [1, 2, 3]]

  void $ launchAff $
    Console.log $ intercalate " == " $ show <$> [res3 [], res4 []]
