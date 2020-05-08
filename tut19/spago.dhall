{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut19"
, dependencies = [ "console", "effect", "either", "prelude", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
