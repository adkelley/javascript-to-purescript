{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut26"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "either"
  , "maybe"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
