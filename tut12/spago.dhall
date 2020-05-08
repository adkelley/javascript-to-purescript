{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut12"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "either"
  , "functions"
  , "maybe"
  , "numbers"
  , "prelude"
  , "psci-support"
  , "strings"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
