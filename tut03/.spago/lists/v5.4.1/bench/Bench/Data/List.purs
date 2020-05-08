module Bench.Data.List where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Performance.Minibench (bench)

import Data.List as L

benchList :: Effect Unit
benchList = do
  log "map"
  log "---"
  benchMap

  where

  benchMap = do
    let nats = L.range 0 999999
        mapFn = map (_ + 1)
        list1000    = L.take 1000 nats
        list2000    = L.take 2000 nats
        list5000    = L.take 5000 nats
        list10000   = L.take 10000 nats
        list100000  = L.take 100000 nats

    log "map: empty list"
    let emptyList = L.Nil
    bench \_ -> mapFn emptyList

    log "map: singleton list"
    let singletonList = L.Cons 0 L.Nil
    bench \_ -> mapFn singletonList

    log $ "map: list (" <> show (L.length list1000) <> " elems)"
    bench \_ -> mapFn list1000

    log $ "map: list (" <> show (L.length list2000) <> " elems)"
    bench \_ -> mapFn list2000

    log $ "map: list (" <> show (L.length list5000) <> " elems)"
    bench \_ -> mapFn list5000

    log $ "map: list (" <> show (L.length list10000) <> " elems)"
    bench \_ -> mapFn list10000

    log $ "map: list (" <> show (L.length list100000) <> " elems)"
    bench \_ -> mapFn list100000
