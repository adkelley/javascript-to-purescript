module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, newTask, rej, res, taskRejected, taskOf)
import Data.Array (fromFoldable, filter, head) as A
import Data.Either (Either(..), either)
import Data.List (List(..), fromFoldable, (:))
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class.Console (log, error) as Console
import Effect.Console (log, logShow)

type Error = String
type ID = Int
type User = { id :: ID
            , name :: String
            , best_friend_id :: ID
            }

wordList :: List String
wordList = ("hello" : "world" : Nil)

numbers :: Array Int
numbers = [2, 400, 5, 1000]

largeNumbers :: Array Int -> Array Int
largeNumbers = A.filter (\x -> x > 100)

larger :: Int -> Int
larger = \x -> x * 2

eitherToTask :: forall a. Either Error a -> TaskE Error a
eitherToTask = either (\e -> taskRejected e) (\a -> taskOf a)

fake :: Int -> User
fake x = { id: x, name: "user1", best_friend_id: (x + 1)}

dbFind :: ID -> TaskE Error (Either Error User)
dbFind id =
  let
    query :: ID -> Either Error User
    query id_ =
      if (id_ > 2)
        then Right $ fake id_
        else Left "not found"
  in
     taskOf $ query id


main :: Effect Unit
main = do
  log "Tutorial 25: Apply Natural Transformations in everyday work"

  log "\nSplit on characters"
  logShow $ fromFoldable $
     (A.fromFoldable wordList) >>= \x -> split (Pattern "") x

  log "\nProve that head is a natural transformation"
  log $ (show $ A.head $ larger <$> (largeNumbers numbers)) <> " == "
    <>  (show $ larger <$> A.head (largeNumbers numbers))

  void $ launchAff $
    let s = "\ndbFind(): "
    in do
     (dbFind 3) >>= eitherToTask >>= \user -> (dbFind user.best_friend_id) >>= eitherToTask
     # fork (\e -> Console.error $ s <> e) (\p -> Console.log (s <> (show p)))
