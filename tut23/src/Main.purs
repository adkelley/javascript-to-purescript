module Main where

import Prelude

import Control.Monad.Task (TaskE, fork, taskOf)
import Data.Map (Map, fromFoldable)
import Data.Traversable (traverse)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Error, launchAff)
import Effect.Class.Console (logShow, errorShow) as Console
import Effect.Console (log)

type Path = String
type Params = String
type Result = String

routes :: Map String String
routes = fromFoldable ["blog:" /\ "/blog", "about:" /\ "/about-us", "home" /\ "/"]

nestedRoutes :: Map String (Array String)
nestedRoutes = fromFoldable ["blog:" /\ ["/blog"], "about:" /\ ["/about-us"], "home:" /\ ["/", "/home"]]

httpGet :: Path -> Params -> TaskE Error Result
httpGet path _ = taskOf $ path <> " result"

main :: Effect Unit
main = do
  log "Tutorial 23: Maintaining structure whilst asyncing"

  log "\nTraverse a Map of routes:"
  void $ launchAff $
    traverse (\path -> httpGet path "{}") routes #
    fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)

  log "\nTwo traversals in the same workflow:"
  void $ launchAff $
    traverse (\paths -> traverse (\path -> httpGet path "{}") paths) nestedRoutes #
    fork (\e -> Console.errorShow e) (\rs -> Console.logShow rs)
