{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut03"
, dependencies =
  [ "console"
  , "effect"
  , "either"
  , "functions"
  , "lists"
  , "maybe"
  , "partial"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
