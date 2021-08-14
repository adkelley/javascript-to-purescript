{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut11"
, dependencies =
  [ "console"
  , "effect"
  , "functions"
  , "integers"
  , "lazy"
  , "maybe"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
