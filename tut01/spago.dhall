{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut01"
, dependencies =
  [ "console"
  , "control"
  , "effect"
  , "integers"
  , "maybe"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
