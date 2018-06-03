module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log, logShow)
import Data.Foldable (foldl, foldr)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Musician (makeMusician, makePerson, setGenre)

type Account = Record
  ( name    :: First String
  , isPaid  :: Conj Boolean
  , points  :: Additive Int
  , friends :: Array String
  )

showAccount :: Account -> String
showAccount { name, isPaid, points, friends } =
  foldr (<>) ""
    [ "{\n", "name: ", show name, "\n"
    , "isPaid: ",  show isPaid, "\n"
    , "points: ",  show points, "\n"
    , "friends: ", show friends, "\n}"
    ]

appendAccount :: Account -> Account -> Account
appendAccount
  { name: a1, isPaid: b1, points: c1, friends: d1 }
  { name: a2, isPaid: b2, points: c2, friends: d2 } =
  { name: a1 <> a2, isPaid: b1 <> b2, points: c1 <> c2, friends: d1 <> d2 }

infixr 5 appendAccount as ++

makeAccount :: String -> Boolean -> Int -> Array String -> Account
makeAccount name isPaid points friends =
 { name: First maybeBlankName, isPaid: Conj isPaid, points: Additive points, friends: friends}
 where
   maybeBlankName =
     if (name /= "")
       then Just name
       else Nothing

acct1 :: Account
acct1 = makeAccount "" true 10 ["Andy"]

acct2 :: Account
acct2 = makeAccount "Nico" false 2 ["Lou"]

acct3 :: Account
acct3 = makeAccount "Christa Päffgen" true 3 ["John", "Sterling"]

main :: Effect Unit
main = do
  log "Record examples"
  logShow $ _.firstName {firstName: "Imogen", lastName: "Heap", age: (Just 39)}
  logShow $ _.age $ makePerson "Imogen" "Heap" (Just 39)
  let immy = makeMusician "Imogen" "Heap" Nothing "Electronic"
  logShow $ _.age immy
  logShow $ _.genre immy
  logShow $ _.genre $ setGenre "Alternative" immy

  log "\nFold Examples on a list (1 : 2 : 3 : Nil)"
  let list = 1 : 2 : 3 : Nil
  log "Associative binary operator, result from foldl & foldr will be equal"
  logShow $ foldl (+) 0 list == foldr (+) 0 list
  log "Non-associative binary operator, result from foldl & foldr will not be equal"
  logShow $ foldl (-) 0 list /= foldr (-) 0 list



  -- semigroups are concatable and associative
  log "\nSemigroup examples"
  log $ showAccount $ acct1 ++ acct2 ++ acct3
  log $ showAccount $ foldr (++) acct1 [acct2, acct3]
  log $ showAccount $ acct1 `appendAccount` acct2 `appendAccount` acct3
