{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut20"
, dependencies = [ "console", "effect", "lists", "prelude", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
