{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut28"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "functions"
  , "node-http"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "simple-json"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
