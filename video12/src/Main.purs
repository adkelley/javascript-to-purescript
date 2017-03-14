module Main where

import Preface

newtype MyTask = Task String

instance functorBox :: Functor MyTask where
 map f (MyTask x) = MyTask (f x)
-- -- inspect: () => 'MyTask($(x))'
instance showMyTask :: Show a => Show (MyTask a) where
  show (MyTask a) = "Box(" <> show a <> ")"

missile :: MyTask (Array String)
missile = sequence [pure "launch missiles", pure "missle"]

-- launchMissiles :: Task (Array String)
-- launchMissiles = missile `bind` (\xs -> map (\x -> x ++ "!") xs)

main :: Task Unit
main = log "hello"
