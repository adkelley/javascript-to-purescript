{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut13"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "node-buffer"
  , "node-fs"
  , "prelude"
  , "psci-support"
  , "strings"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
