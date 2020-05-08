{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut15"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "globals"
  , "prelude"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
