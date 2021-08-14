{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "tut10"
, dependencies =
  [ "console"
  , "effect"
  , "foldable-traversable"
  , "group"
  , "lists"
  , "maybe"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
