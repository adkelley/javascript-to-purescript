
# Table of Contents



module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, taskOf, taskRejected)
import Data.Array (foldl, head, intercalate)
import Data.Box (Box(..))
import Data.Either (Either(..), either)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class.Console (errorShow, log, logShow) as Console
import Effect.Console (log)

type Error = String

boxToEither :: forall b. Box b -> Either Error b
boxToEither (Box b) = Right b

&#x2013; Law of Natural Transformations
&#x2013; nt(x).map(f) == nt(x.map(f))

&#x2013; nt(x).map(f)
res1 :: Either Error Int
res1 = (\x -> x \* 2) <$> (boxToEither $ Box 100)

&#x2013; nt(x.map(f))
res2 :: Either Error Int
res2 = boxToEither $ (\x -> x \* 2) <$> Box 100

&#x2013; nt(x).map(f)
res3 :: Maybe Int
res3 = (\x -> x + 1) <$> head [1, 2, 3]

&#x2013; nt(x.map(f))
res4 :: Maybe Int
res4 = head $ (\x -> x + 1) <$> [1, 2, 3]

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
  fork (\e -> Console.errorShow $ "Error: " <> e) (\s -> Console.log $ "Result: " <> s)

void $ launchAff $
    Console.logShow $ boxToEither $ Box 100

void $ launchAff $
  Console.log $ intercalate " " $ show <$> [res1, res2]

void $ launchAff $
  Console.log $ intercalate " " $ show <$> [res3, res4]

