{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut07"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "generics-rep"
  , "lists"
  , "maybe"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
