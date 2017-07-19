module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Data.Maybe.First (First(..))
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))

type Account = Record
  ( name    :: First String
  , isPaid  :: Conj Boolean
  , points  :: Additive Int
  , friends :: Array String
  )
-- type Account =
--   { name    :: First String
--   , isPaid  :: Conj Boolean
--   , points  :: Additive Int
--   , friends :: Array String
--   }


showAccount :: Account -> String
showAccount { name, isPaid, points, friends } =
  foldr (<>) ""
    [ "{ name: ", show name, ",\n  "
    , "isPaid: ", show isPaid, ",\n  "
    , "points: ", show points, ",\n  "
    , "friends: ", show friends, "  }"
    ]

appendAccount :: Account -> Account -> Account
appendAccount
  { name: a1, isPaid: b1, points: c1, friends: d1 }
  { name: a2, isPaid: b2, points: c2, friends: d2 } =
  { name: a1 <> a2, isPaid: b1 <> b2, points: c1 <> c2, friends: d1 <> d2 }

infixr 5 appendAccount as ++

makeAccount :: String -> Boolean -> Int -> Array String -> Account
makeAccount name isPaid points friends =
 { name: First maybeBlank, isPaid: Conj isPaid, points: Additive points, friends: friends}
 where
   maybeBlank =
     if (name /= "")
       then Just name
       else Nothing

acct1 :: Account
acct1 = makeAccount "" true 10 ["Andy"]

acct2 :: Account
acct2 = makeAccount "Nico" false 2 ["Lou"]

acct3 :: Account
acct3 = makeAccount "Christa Päffgen" true 3 ["John", "Sterling"]

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  -- semigroups are concatable and associative
  log "Semigroup examples"
  log $ showAccount $ acct1 ++ acct2 ++ acct3
  log $ showAccount $ foldr (++) acct1 [acct2, acct3]
  log $ showAccount $ acct1 `appendAccount` acct2 `appendAccount` acct3
