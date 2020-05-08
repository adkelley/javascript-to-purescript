module Data.Newtype where

import Prelude

import Data.Function (on)
import Data.Monoid.Additive (Additive(..))
import Data.Monoid.Conj (Conj(..))
import Data.Monoid.Disj (Disj(..))
import Data.Monoid.Dual (Dual(..))
import Data.Monoid.Endo (Endo(..))
import Data.Monoid.Multiplicative (Multiplicative(..))
import Data.Semigroup.First (First(..))
import Data.Semigroup.Last (Last(..))

-- | A type class for `newtype`s to enable convenient wrapping and unwrapping,
-- | and the use of the other functions in this module.
-- |
-- | The compiler can derive instances of `Newtype` automatically:
-- |
-- | ``` purescript
-- | newtype EmailAddress = EmailAddress String
-- |
-- | derive instance newtypeEmailAddress :: Newtype EmailAddress _
-- | ```
-- |
-- | Note that deriving for `Newtype` instances requires that the type be
-- | defined as `newtype` rather than `data` declaration (even if the `data`
-- | structurally fits the rules of a `newtype`), and the use of a wildcard for
-- | the wrapped type.
-- |
-- | Instances must obey the following laws:
-- | ``` purescript
-- | unwrap <<< wrap = id
-- | wrap <<< unwrap = id
-- | ```
class Newtype t a | t -> a where
  wrap :: a -> t
  unwrap :: t -> a

instance newtypeAdditive :: Newtype (Additive a) a where
  wrap = Additive
  unwrap (Additive a) = a

instance newtypeMultiplicative :: Newtype (Multiplicative a) a where
  wrap = Multiplicative
  unwrap (Multiplicative a) = a

instance newtypeConj :: Newtype (Conj a) a where
  wrap = Conj
  unwrap (Conj a) = a

instance newtypeDisj :: Newtype (Disj a) a where
  wrap = Disj
  unwrap (Disj a) = a

instance newtypeDual :: Newtype (Dual a) a where
  wrap = Dual
  unwrap (Dual a) = a

instance newtypeEndo :: Newtype (Endo c a) (c a a) where
  wrap = Endo
  unwrap (Endo a) = a

instance newtypeFirst :: Newtype (First a) a where
  wrap = First
  unwrap (First a) = a

instance newtypeLast :: Newtype (Last a) a where
  wrap = Last
  unwrap (Last a) = a

-- | Given a constructor for a `Newtype`, this returns the appropriate `unwrap`
-- | function.
un :: forall t a. Newtype t a => (a -> t) -> t -> a
un _ = unwrap

-- | Deprecated previous name of `un`.
op :: forall t a. Newtype t a => (a -> t) -> t -> a
op = un

-- | This combinator is for when you have a higher order function that you want
-- | to use in the context of some newtype - `foldMap` being a common example:
-- |
-- | ``` purescript
-- | ala Additive foldMap [1,2,3,4] -- 10
-- | ala Multiplicative foldMap [1,2,3,4] -- 24
-- | ala Conj foldMap [true, false] -- false
-- | ala Disj foldMap [true, false] -- true
-- | ```
ala
  :: forall f t a s b
   . Functor f
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> ((b -> s) -> f t)
  -> f a
ala _ f = map unwrap (f wrap)

-- | Similar to `ala` but useful for cases where you want to use an additional
-- | projection with the higher order function:
-- |
-- | ``` purescript
-- | alaF Additive foldMap String.length ["hello", "world"] -- 10
-- | alaF Multiplicative foldMap Math.abs [1.0, -2.0, 3.0, -4.0] -- 24.0
-- | ```
-- |
-- | The type admits other possibilities due to the polymorphic `Functor`
-- | constraints, but the case described above works because ((->) a) is a
-- | `Functor`.
alaF
  :: forall f g t a s b
   . Functor f
  => Functor g
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> (f t -> g s)
  -> f a
  -> g b
alaF _ f = map unwrap <<< f <<< map wrap

-- | Lifts a function operate over newtypes. This can be used to lift a
-- | function to manipulate the contents of a single newtype, somewhat like
-- | `map` does for a `Functor`:
-- |
-- | ``` purescript
-- | newtype Label = Label String
-- | derive instance newtypeLabel :: Newtype Label _
-- |
-- | toUpperLabel :: Label -> Label
-- | toUpperLabel = over Label String.toUpper
-- | ```
-- |
-- | But the result newtype is polymorphic, meaning the result can be returned
-- | as an alternative newtype:
-- |
-- | ``` purescript
-- | newtype UppercaseLabel = UppercaseLabel String
-- | derive instance newtypeUppercaseLabel :: Newtype UppercaseLabel _
-- |
-- | toUpperLabel' :: Label -> UppercaseLabel
-- | toUpperLabel' = over Label String.toUpper
-- | ```
over
  :: forall t a s b
   . Newtype t a
  => Newtype s b
  => (a -> t)
  -> (a -> b)
  -> t
  -> s
over _ f = wrap <<< f <<< unwrap

-- | Much like `over`, but where the lifted function operates on values in a
-- | `Functor`:
-- |
-- | ``` purescript
-- | findLabel :: String -> Array Label -> Maybe Label
-- | findLabel s = overF Label (Foldable.find (_ == s))
-- | ```
-- |
-- | The above example also demonstrates that the functor type is polymorphic
-- | here too, the input is an `Array` but the result is a `Maybe`.
overF
  :: forall f g t a s b
   . Functor f
  => Functor g
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> (f a -> g b)
  -> f t
  -> g s
overF _ f = map wrap <<< f <<< map unwrap

-- | The opposite of `over`: lowers a function that operates on `Newtype`d
-- | values to operate on the wrapped value instead.
-- |
-- | ``` purescript
-- | newtype Degrees = Degrees Number
-- | derive instance newtypeDegrees :: Newtype Degrees _
-- |
-- | newtype NormalDegrees = NormalDegrees Number
-- | derive instance newtypeNormalDegrees :: Newtype NormalDegrees _
-- |
-- | normaliseDegrees :: Degrees -> NormalDegrees
-- | normaliseDegrees (Degrees deg) = NormalDegrees (deg % 360.0)
-- |
-- | asNormalDegrees :: Number -> Number
-- | asNormalDegrees = under Degrees normaliseDegrees
-- | ```
-- |
-- | As with `over` the `Newtype` is polymorphic, as illustrated in the example
-- | above - both `Degrees` and `NormalDegrees` are instances of `Newtype`,
-- | so even though `normaliseDegrees` changes the result type we can still put
-- | a `Number` in and get a `Number` out via `under`.
under
  :: forall t a s b
   . Newtype t a
  => Newtype s b
  => (a -> t)
  -> (t -> s)
  -> a
  -> b
under _ f = unwrap <<< f <<< wrap

-- | Much like `under`, but where the lifted function operates on values in a
-- | `Functor`:
-- |
-- | ``` purescript
-- | newtype EmailAddress = EmailAddress String
-- | derive instance newtypeEmailAddress :: Newtype EmailAddress _
-- |
-- | isValid :: EmailAddress -> Boolean
-- | isValid x = false -- imagine a slightly less strict predicate here
-- |
-- | findValidEmailString :: Array String -> Maybe String
-- | findValidEmailString = underF EmailAddress (Foldable.find isValid)
-- | ```
-- |
-- | The above example also demonstrates that the functor type is polymorphic
-- | here too, the input is an `Array` but the result is a `Maybe`.
underF
  :: forall f g t a s b
   . Functor f
  => Functor g
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> (f t -> g s)
  -> f a
  -> g b
underF _ f = map unwrap <<< f <<< map wrap

-- | Lifts a binary function to operate over newtypes.
-- |
-- | ``` purescript
-- | newtype Meter = Meter Int
-- | derive newtype instance newtypeMeter :: Newtype Meter _
-- | newtype SquareMeter = SquareMeter Int
-- | derive newtype instance newtypeSquareMeter :: Newtype SquareMeter _
-- |
-- | area :: Meter -> Meter -> SquareMeter
-- | area = over2 Meter (*)
-- | ```
-- |
-- | The above example also demonstrates that the return type is polymorphic
-- | here too.
over2
  :: forall t a s b
   . Newtype t a
  => Newtype s b
  => (a -> t)
  -> (a -> a -> b)
  -> t
  -> t
  -> s
over2 _ f = compose wrap <<< f `on` unwrap

-- | Much like `over2`, but where the lifted binary function operates on
-- | values in a `Functor`.
overF2
  :: forall f g t a s b
   . Functor f
  => Functor g
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> (f a -> f a -> g b)
  -> f t
  -> f t
  -> g s
overF2 _ f = compose (map wrap) <<< f `on` map unwrap

-- | The opposite of `over2`: lowers a binary function that operates on `Newtype`d
-- | values to operate on the wrapped value instead.
under2
  :: forall t a s b
   . Newtype t a
  => Newtype s b
  => (a -> t)
  -> (t -> t -> s)
  -> a
  -> a
  -> b
under2 _ f = compose unwrap <<< f `on` wrap

-- | Much like `under2`, but where the lifted binary function operates on
-- | values in a `Functor`.
underF2
  :: forall f g t a s b
   . Functor f
  => Functor g
  => Newtype t a
  => Newtype s b
  => (a -> t)
  -> (f t -> f t -> g s)
  -> f a
  -> f a
  -> g b
underF2 _ f = compose (map unwrap) <<< f `on` map wrap

-- | Similar to the function from the `Traversable` class, but operating within
-- | a newtype instead.
traverse
  :: forall f t a
   . Functor f
  => Newtype t a
  => (a -> t)
  -> (a -> f a)
  -> t
  -> f t
traverse _ f = map wrap <<< f <<< unwrap

-- | Similar to the function from the `Distributive` class, but operating within
-- | a newtype instead.
collect
  :: forall f t a
   . Functor f
  => Newtype t a
  => (a -> t)
  -> (f a -> a)
  -> f t
  -> t
collect _ f = wrap <<< f <<< map unwrap
