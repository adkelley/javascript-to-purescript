{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut02"
, dependencies =
  [ "console", "effect", "functions", "prelude", "psci-support", "strings" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
