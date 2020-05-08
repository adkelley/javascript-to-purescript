module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Newtype (class Newtype, unwrap)
import Type.Equality (class TypeEquals, to, from)

newtype RecordNewtype = RecordNewtype
  { message :: String }

instance newtypeRecordNewtype ::
  TypeEquals inner { message :: String }
    => Newtype RecordNewtype inner where
  wrap = RecordNewtype <<< to
  unwrap (RecordNewtype rec) = from rec

main :: Effect Unit
main = log (unwrap (RecordNewtype { message: "Done" })).message
