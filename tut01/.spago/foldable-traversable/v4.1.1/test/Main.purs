module Test.Main where

import Prelude

import Data.Bifoldable (class Bifoldable, bifoldl, bifoldr, bifoldMap, bifoldrDefault, bifoldlDefault, bifoldMapDefaultR, bifoldMapDefaultL)
import Data.Bifunctor (class Bifunctor, bimap)
import Data.Bitraversable (class Bitraversable, bisequenceDefault, bitraverse, bisequence, bitraverseDefault)
import Data.Foldable (class Foldable, find, findMap, fold, indexl, indexr, foldMap, foldMapDefaultL, foldMapDefaultR, foldl, foldlDefault, foldr, foldrDefault, length, maximum, maximumBy, minimum, minimumBy, null, surroundMap)
import Data.FoldableWithIndex (class FoldableWithIndex, findWithIndex, foldMapWithIndex, foldMapWithIndexDefaultL, foldMapWithIndexDefaultR, foldlWithIndex, foldlWithIndexDefault, foldrWithIndex, foldrWithIndexDefault, surroundMapWithIndex)
import Data.Function (on)
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Int (toNumber, pow)
import Data.Maybe (Maybe(..))
import Data.Monoid.Additive (Additive(..))
import Data.Newtype (unwrap)
import Data.Traversable (class Traversable, sequenceDefault, traverse, sequence, traverseDefault)
import Data.TraversableWithIndex (class TraversableWithIndex, traverseWithIndex)
import Effect (Effect, foreachE)
import Effect.Console (log)
import Math (abs)
import Test.Assert (assert, assert')
import Unsafe.Coerce (unsafeCoerce)

foreign import arrayFrom1UpTo :: Int -> Array Int
foreign import arrayReplicate :: forall a. Int -> a -> Array a

foldableLength :: forall f a. Foldable f => f a -> Int
foldableLength = unwrap <<< foldMap (const (Additive 1))

-- Ensure that a value is evaluated 'lazily' by treating it as an Eff action.
deferEff :: forall a. (Unit -> a) -> Effect a
deferEff = unsafeCoerce

main :: Effect Unit
main = do
  log "Test foldableArray instance"
  testFoldableArrayWith 20

  assert $ foldMapDefaultL (\x -> [x]) [1, 2] == [1, 2]

  log "Test foldableArray instance is stack safe"
  testFoldableArrayWith 20000

  log "Test foldMapDefaultL"
  testFoldableFoldMapDefaultL 20

  log "Test foldMapDefaultR"
  testFoldableFoldMapDefaultR 20

  log "Test foldlDefault"
  testFoldableFoldlDefault 20

  log "Test foldrDefault"
  testFoldableFoldrDefault 20

  foreachE [1,2,3,4,5,10,20] \i -> do
    log $ "Test traversableArray instance with an array of size: " <> show i
    testTraversableArrayWith i

  log "Test traversableArray instance is stack safe"
  testTraversableArrayWith 20000

  log "Test traverseDefault"
  testTraverseDefault 20

  log "Test sequenceDefault"
  testSequenceDefault 20

  log "Test foldableWithIndexArray instance"
  testFoldableWithIndexArrayWith 20

  log "Test foldableWithIndexArray instance is stack safe"
  testFoldableWithIndexArrayWith 20000

  log "Test FoldableWithIndex laws for array instance"
  testFoldableWithIndexLawsOn
    ["a", "b", "c"]
    (\i x -> [Tuple i x])
    (\x -> [x])

  log "Test traversableArrayWithIndex instance"
  testTraversableWithIndexArrayWith 20

  log "Test Bifoldable on `inclusive or`"
  testBifoldableIOrWith identity 10 100 42

  log "Test bifoldMapDefaultL"
  testBifoldableIOrWith BFML 10 100 42

  log "Test bifoldMapDefaultR"
  testBifoldableIOrWith BFMR 10 100 42

  log "Test bifoldlDefault"
  testBifoldableIOrWith BFLD 10 100 42

  log "Test bifoldrDefault"
  testBifoldableIOrWith BFRD 10 100 42

  log "Test Bitraversable on `inclusive or`"
  testBitraversableIOrWith identity

  log "Test bitraverseDefault"
  testBitraversableIOrWith BTD

  log "Test bisequenceDefault"
  testBitraversableIOrWith BSD

  log "Test indexl"
  assert $ indexl 2 [1, 5, 10] == Just 10
  assert $ indexl 0 [1, 5, 10] == Just 1
  assert $ indexl 9 [1, 5, 10] == Nothing

  log "Test indexr"
  assert $ indexr 2 [1, 5, 10] == Just 1
  assert $ indexr 0 [1, 5, 10] == Just 10
  assert $ indexr 9 [1, 5, 10] == Nothing

  log "Test find"
  assert $ find (_ == 10) [1, 5, 10] == Just 10
  assert $ find (\x -> x `mod` 2 == 0) [1, 4, 10] == Just 4

  log "Test findWithIndex"
  assert $
    case findWithIndex (\i x -> i `mod` 2 == 0 && x `mod` 2 == 0) [1, 2, 4, 6] of
      Nothing -> false
      Just { index, value } -> index == 2 && value == 4

  log "Test findMap" *> do
    let pred x = if x > 5 then Just (x * 100) else Nothing
    assert $ findMap pred [1, 5, 10, 20] == Just 1000

  log "Test maximum"
  assert $ maximum (arrayFrom1UpTo 10) == Just 10

  log "Test maximumBy"
  assert $
    maximumBy (compare `on` abs)
              (map (negate <<< toNumber) (arrayFrom1UpTo 10))
      == Just (-10.0)

  log "Test minimum"
  assert $ minimum (arrayFrom1UpTo 10) == Just 1

  log "Test minimumBy"
  assert $
    minimumBy (compare `on` abs)
              (map (negate <<< toNumber) (arrayFrom1UpTo 10))
      == Just (-1.0)

  log "Test null"
  assert $ null Nothing == true
  assert $ null (Just 1) == false
  assert $ null [] == true
  assert $ null [0] == false
  assert $ null [0,1] == false

  log "Test length"
  assert $ length Nothing == 0
  assert $ length (Just 1) == 1
  assert $ length [] == 0
  assert $ length [1] == 1
  assert $ length [1, 2] == 2

  log "Test surroundMap"
  assert $ "*" == surroundMap "*" show ([] :: Array Int)
  assert $ "*1*" == surroundMap "*" show [1]
  assert $ "*1*2*" == surroundMap "*" show [1, 2]
  assert $ "*1*2*3*" == surroundMap "*" show [1, 2, 3]

  log "Test surroundMapWithIndex"
  assert $ "*" == surroundMapWithIndex "*" (\i x -> show i <> x) []
  assert $ "*0a*" == surroundMapWithIndex "*" (\i x -> show i <> x) ["a"]
  assert $ "*0a*1b*" == surroundMapWithIndex "*" (\i x -> show i <> x) ["a", "b"]
  assert $ "*0a*1b*2c*" == surroundMapWithIndex "*" (\i x -> show i <> x) ["a", "b", "c"]

  log "All done!"


testFoldableFWith
  :: forall f
   . Foldable f
  => Eq (f Int)
  => (Int -> f Int)
  -> Int
  -> Effect Unit
testFoldableFWith f n = do
  let dat = f n
  let expectedSum = (n / 2) * (n + 1)

  assert $ foldr (+) 0 dat == expectedSum
  assert $ foldl (+) 0 dat == expectedSum
  assert $ foldMap Additive dat == Additive expectedSum

testFoldableArrayWith :: Int -> Effect Unit
testFoldableArrayWith = testFoldableFWith arrayFrom1UpTo

testFoldableWithIndexFWith
  :: forall f
   . FoldableWithIndex Int f
  => Eq (f Int)
  => (Int -> f Int)
  -> Int
  -> Effect Unit
testFoldableWithIndexFWith f n = do
  let dat = f n
  -- expectedSum = \Sum_{1 <= i <= n} i * i
  let expectedSum = n * (n + 1) * (2 * n + 1) / 6

  assert $ foldrWithIndex (\i x y -> (i + 1) * x + y) 0 dat == expectedSum
  assert $ foldlWithIndex (\i y x -> y + (i + 1) * x) 0 dat == expectedSum
  assert $ foldMapWithIndex (\i x -> Additive $ (i + 1) * x) dat == Additive expectedSum

testFoldableWithIndexArrayWith :: Int -> Effect Unit
testFoldableWithIndexArrayWith = testFoldableWithIndexFWith arrayFrom1UpTo


data Tuple a b = Tuple a b
derive instance eqTuple :: (Eq a, Eq b) => Eq (Tuple a b)

-- test whether foldable laws hold, using foldMap and ifoldMap
testFoldableWithIndexLawsOn
  :: forall f i a m n
   . FoldableWithIndex i f
  => FunctorWithIndex i f
  => Monoid m
  => Monoid n
  => Eq m
  => Eq n
  => f a
  -> (i -> a -> m)
  -> (a -> n)
  -> Effect Unit
testFoldableWithIndexLawsOn c f g = do
  -- compatibility with FunctorWithIndex (not strictly necessary for a valid
  -- instance, but it's likely an error if this does not hold)
  assert $ foldMapWithIndex f c == fold (mapWithIndex f c)

  -- Compatiblity with Foldable
  assert $ foldMap g c == foldMapWithIndex (const g) c

  -- FoldableWithIndex laws
  assert $ foldMapWithIndex f c == foldMapWithIndexDefaultL f c
  assert $ foldMapWithIndex f c == foldMapWithIndexDefaultR f c

  -- These follow from the above laws, but they test whether ifoldlDefault and
  -- ifoldrDefault have been specified correctly.
  assert $ foldMapWithIndex f c == foldlWithIndexDefault (\i y x -> y <> f i x) mempty c
  assert $ foldMapWithIndex f c == foldrWithIndexDefault (\i x y -> f i x <> y) mempty c

testTraversableFWith
  :: forall f
   . Traversable f
  => Eq (f Int)
  => (Int -> f Int)
  -> Int
  -> Effect Unit
testTraversableFWith f n = do
  let dat = f n
  let len = foldableLength dat

  _ <- traverse pure dat

  assert' "traverse Just == Just" $ traverse Just dat == Just dat
  assert' "traverse pure == pure (Array)" $ traverse pure dat == [dat]

  when (len <= 10) do
    result <- deferEff \_ -> traverse (\x -> [x,x]) dat == arrayReplicate (pow 2 len) dat
    assert' "traverse with Array as underlying applicative" result

  assert' "traverse (const Nothing) == const Nothing" $
    traverse (const Nothing :: Int -> Maybe Int) dat == Nothing

  assert' "sequence <<< map f == traverse f" $
    sequence (map Just dat) == traverse Just dat

  assert' "underlying applicative" $
    (traverse pure dat :: Unit -> f Int) unit == dat

testTraversableArrayWith :: Int -> Effect Unit
testTraversableArrayWith = testTraversableFWith arrayFrom1UpTo

testTraversableWithIndexFWith
  :: forall f
   . TraversableWithIndex Int f
  => Eq (f (Tuple Int Int))
  => Eq (f Int)
  => (Int -> f Int)
  -> Int
  -> Effect Unit
testTraversableWithIndexFWith f n = do
  let dat = f n

  assert $ traverseWithIndex (\i -> Just <<< Tuple i) dat == Just (mapWithIndex Tuple dat)
  assert $ traverseWithIndex (const Just) dat == traverse Just dat
  assert $ traverseWithIndex (\i -> pure <<< Tuple i) dat == [mapWithIndex Tuple dat]
  assert $
    traverseWithIndex (const pure :: Int -> Int -> Array Int) dat ==
    traverse pure dat

testTraversableWithIndexArrayWith
  :: Int -> Effect Unit
testTraversableWithIndexArrayWith = testTraversableWithIndexFWith arrayFrom1UpTo

-- structures for testing default `Foldable` implementations

newtype FoldMapDefaultL a = FML (Array a)
newtype FoldMapDefaultR a = FMR (Array a)
newtype FoldlDefault    a = FLD (Array a)
newtype FoldrDefault    a = FRD (Array a)

instance eqFML :: (Eq a) => Eq (FoldMapDefaultL a) where eq (FML l) (FML r) = l == r
instance eqFMR :: (Eq a) => Eq (FoldMapDefaultR a) where eq (FMR l) (FMR r) = l == r
instance eqFLD :: (Eq a) => Eq (FoldlDefault a)    where eq (FLD l) (FLD r) = l == r
instance eqFRD :: (Eq a) => Eq (FoldrDefault a)    where eq (FRD l) (FRD r) = l == r

-- implemented `foldl` and `foldr`, but default `foldMap` using `foldl`
instance foldableFML :: Foldable FoldMapDefaultL where
  foldMap f         = foldMapDefaultL f
  foldl f u (FML a) = foldl f u a
  foldr f u (FML a) = foldr f u a

-- implemented `foldl` and `foldr`, but default `foldMap`, using `foldr`
instance foldableFMR :: Foldable FoldMapDefaultR where
  foldMap f         = foldMapDefaultR f
  foldl f u (FMR a) = foldl f u a
  foldr f u (FMR a) = foldr f u a

-- implemented `foldMap` and `foldr`, but default `foldMap`
instance foldableDFL :: Foldable FoldlDefault where
  foldMap f (FLD a) = foldMap f a
  foldl f u         = foldlDefault f u
  foldr f u (FLD a) = foldr f u a

-- implemented `foldMap` and `foldl`, but default `foldr`
instance foldableDFR :: Foldable FoldrDefault where
  foldMap f (FRD a) = foldMap f a
  foldl f u (FRD a) = foldl f u a
  foldr f u         = foldrDefault f u

testFoldableFoldMapDefaultL :: Int -> Effect Unit
testFoldableFoldMapDefaultL = testFoldableFWith (FML <<< arrayFrom1UpTo)

testFoldableFoldMapDefaultR :: Int -> Effect Unit
testFoldableFoldMapDefaultR = testFoldableFWith (FMR <<< arrayFrom1UpTo)

testFoldableFoldlDefault :: Int -> Effect Unit
testFoldableFoldlDefault = testFoldableFWith (FLD <<< arrayFrom1UpTo)

testFoldableFoldrDefault :: Int -> Effect Unit
testFoldableFoldrDefault = testFoldableFWith (FRD <<< arrayFrom1UpTo)


-- structures for testing default `Traversable` implementations

newtype TraverseDefault a = TD (Array a)
newtype SequenceDefault a = SD (Array a)

instance eqTD :: (Eq a) => Eq (TraverseDefault a) where eq (TD l) (TD r) = l == r
instance eqSD :: (Eq a) => Eq (SequenceDefault a) where eq (SD l) (SD r) = l == r

instance functorTD :: Functor TraverseDefault where map f (TD a) = TD (map f a)
instance functorSD :: Functor SequenceDefault where map f (SD a) = SD (map f a)

instance foldableTD :: Foldable TraverseDefault where
  foldMap f (TD a) = foldMap f a
  foldr f u (TD a) = foldr f u a
  foldl f u (TD a) = foldl f u a

instance foldableSD :: Foldable SequenceDefault where
  foldMap f (SD a) = foldMap f a
  foldr f u (SD a) = foldr f u a
  foldl f u (SD a) = foldl f u a

instance traversableTD :: Traversable TraverseDefault where
  traverse f      = traverseDefault f
  sequence (TD a) = map TD (sequence a)

instance traversableSD :: Traversable SequenceDefault where
  traverse f (SD a) = map SD (traverse f a)
  sequence m        = sequenceDefault m

testTraverseDefault :: Int -> Effect Unit
testTraverseDefault = testTraversableFWith (TD <<< arrayFrom1UpTo)

testSequenceDefault :: Int -> Effect Unit
testSequenceDefault = testTraversableFWith (SD <<< arrayFrom1UpTo)


-- structure for testing bifoldable, picked `inclusive or` as it has both products and sums

data IOr l r = Both l r | Fst l | Snd r

instance eqIOr :: (Eq l, Eq r) => Eq (IOr l r) where
  eq (Both lFst lSnd) (Both rFst rSnd) = (lFst == rFst) && (lSnd == rSnd)
  eq (Fst l)          (Fst r)          = l == r
  eq (Snd l)          (Snd r)          = l == r
  eq _                _                = false

instance bifoldableIOr :: Bifoldable IOr where
  bifoldr l r u (Both fst snd) = l fst (r snd u)
  bifoldr l r u (Fst fst)      = l fst u
  bifoldr l r u (Snd snd)      = r snd u

  bifoldl l r u (Both fst snd) = r (l u fst) snd
  bifoldl l r u (Fst fst)      = l u fst
  bifoldl l r u (Snd snd)      = r u snd

  bifoldMap l r (Both fst snd) = l fst <> r snd
  bifoldMap l r (Fst fst)      = l fst
  bifoldMap l r (Snd snd)      = r snd

instance bifunctorIOr :: Bifunctor IOr where
  bimap f g (Both fst snd) = Both (f fst) (g snd)
  bimap f g (Fst fst)      = Fst (f fst)
  bimap f g (Snd snd)      = Snd (g snd)

instance bitraversableIOr :: Bitraversable IOr where
  bitraverse f g (Both fst snd) = Both <$> f fst <*> g snd
  bitraverse f g (Fst fst)      = Fst <$> f fst
  bitraverse f g (Snd snd)      = Snd <$> g snd

  bisequence (Both fst snd) = Both <$> fst <*> snd
  bisequence (Fst fst)      = Fst <$> fst
  bisequence (Snd snd)      = Snd <$> snd

testBifoldableIOrWith
  :: forall t
   . Bifoldable t
  => Eq (t Int Int)
  => (forall l r. IOr l r -> t l r)
  -> Int
  -> Int
  -> Int
  -> Effect Unit
testBifoldableIOrWith lift fst snd u = do
  assert $ bifoldr (+) (*) u (lift $ Both fst snd) == fst + (snd * u)
  assert $ bifoldr (+) (*) u (lift $ Fst fst)      == fst + u
  assert $ bifoldr (+) (*) u (lift $ Snd snd)      == snd * u

  assert $ bifoldl (+) (*) u (lift $ Both fst snd) == (u + fst) * snd
  assert $ bifoldl (+) (*) u (lift $ Fst fst)      == u + fst
  assert $ bifoldl (+) (*) u (lift $ Snd snd)      == u * snd

  assert $ bifoldMap Additive Additive (lift $ Both fst snd) == Additive (fst + snd)
  assert $ bifoldMap Additive Additive (lift $ Fst fst)      == Additive fst
  assert $ bifoldMap Additive Additive (lift $ Snd snd)      == Additive snd

testBitraversableIOrWith
  :: forall t
   . Bitraversable t
  => Eq (t Boolean Boolean)
  => (forall l r. IOr l r -> t l r)
  -> Effect Unit
testBitraversableIOrWith lift = do
  let just a = Just (lift a)
  assert $ bisequence (lift (Both (Just true) (Just false))) == just (Both true false)
  assert $ bisequence (lift (Fst (Just true)))               == just (Fst true  :: IOr Boolean Boolean)
  assert $ bisequence (lift (Snd (Just false)))              == just (Snd false :: IOr Boolean Boolean)
  assert $ bitraverse Just Just (lift (Both true false))     == just (Both true false)
  assert $ bitraverse Just Just (lift (Fst true))            == just (Fst true  :: IOr Boolean Boolean)
  assert $ bitraverse Just Just (lift (Snd false))           == just (Snd false :: IOr Boolean Boolean)


-- structures for testing default `Bifoldable` implementations

newtype BifoldMapDefaultL l r = BFML (IOr l r)
newtype BifoldMapDefaultR l r = BFMR (IOr l r)
newtype BifoldlDefault    l r = BFLD (IOr l r)
newtype BifoldrDefault    l r = BFRD (IOr l r)

instance eqBFML :: (Eq l, Eq r) => Eq (BifoldMapDefaultL l r) where eq (BFML l) (BFML r) = l == r
instance eqBFMR :: (Eq l, Eq r) => Eq (BifoldMapDefaultR l r) where eq (BFMR l) (BFMR r) = l == r
instance eqBFLD :: (Eq l, Eq r) => Eq (BifoldlDefault l r)    where eq (BFLD l) (BFLD r) = l == r
instance eqBFRD :: (Eq l, Eq r) => Eq (BifoldrDefault l r)    where eq (BFRD l) (BFRD r) = l == r

instance bifoldableBFML :: Bifoldable BifoldMapDefaultL where
  bifoldMap f g m        = bifoldMapDefaultL f g m
  bifoldr f g u (BFML m) = bifoldr f g u m
  bifoldl f g u (BFML m) = bifoldl f g u m

instance bifoldableBFMR :: Bifoldable BifoldMapDefaultR where
  bifoldMap f g m        = bifoldMapDefaultR f g m
  bifoldr f g u (BFMR m) = bifoldr f g u m
  bifoldl f g u (BFMR m) = bifoldl f g u m

instance bifoldableBFLD :: Bifoldable BifoldlDefault where
  bifoldMap f g (BFLD m) = bifoldMap f g m
  bifoldr f g u (BFLD m) = bifoldr f g u m
  bifoldl f g u m        = bifoldlDefault f g u m

instance bifoldableBFRD :: Bifoldable BifoldrDefault where
  bifoldMap f g (BFRD m) = bifoldMap f g m
  bifoldr f g u m        = bifoldrDefault f g u m
  bifoldl f g u (BFRD m) = bifoldl f g u m


-- structures for testing default `Bitraversable` implementations

newtype BitraverseDefault l r = BTD (IOr l r)
newtype BisequenceDefault l r = BSD (IOr l r)

instance eqBTD :: (Eq l, Eq r) => Eq (BitraverseDefault l r) where eq (BTD l) (BTD r) = l == r
instance eqBSD :: (Eq l, Eq r) => Eq (BisequenceDefault l r) where eq (BSD l) (BSD r) = l == r

instance bifunctorBTD :: Bifunctor BitraverseDefault where bimap f g (BTD m) = BTD (bimap f g m)
instance bifunctorBSD :: Bifunctor BisequenceDefault where bimap f g (BSD m) = BSD (bimap f g m)

instance bifoldableBTD :: Bifoldable BitraverseDefault where
  bifoldMap f g (BTD m) = bifoldMap f g m
  bifoldr f g u (BTD m) = bifoldr f g u m
  bifoldl f g u (BTD m) = bifoldl f g u m

instance bifoldableBSD :: Bifoldable BisequenceDefault where
  bifoldMap f g (BSD m) = bifoldMap f g m
  bifoldr f g u (BSD m) = bifoldr f g u m
  bifoldl f g u (BSD m) = bifoldl f g u m

instance bitraversableBTD :: Bitraversable BitraverseDefault where
  bitraverse f g     = bitraverseDefault f g
  bisequence (BTD m) = map BTD (bisequence m)

instance bitraversableBSD :: Bitraversable BisequenceDefault where
  bitraverse f g (BSD m) = map BSD (bitraverse f g m)
  bisequence m           = bisequenceDefault m
