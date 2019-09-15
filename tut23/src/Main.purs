module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, taskOf)
import Data.Map.Internal (insert, singleton)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Error, launchAff)
import Effect.Class.Console (logShow, errorShow) as Console
import Effect.Console (log)

type Route = String
type Params = String
type Result = String

httpGet :: Route -> Params -> TaskE Error Result
httpGet route _ = taskOf $ route <> " result"

main :: Effect Unit
main = do
  log "Tutorial 23: Maintaining structure whilst asyncing"
  let routes = insert "blog:" "/blog" $ insert "about:" "/about-us" $ singleton "home:" "/"
  let routes_ = insert "blog:" ["/blog"] $ insert "about:" ["/about-us"] $ singleton "home:" ["/", "/home"]

  void $ launchAff $
    traverse (\route -> httpGet route "{}") routes #
    fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)

  -- void $ launchAff $
  --   traverse (\route -> httpGet route "{}") routes_ #
  --   traverse (\route -> httpGet route "{}") routes_ #
  --   fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)
