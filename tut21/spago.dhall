{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut21"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "identity"
  , "integers"
  , "js-timers"
  , "prelude"
  , "psci-support"
  , "strings"
  , "transformers"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
