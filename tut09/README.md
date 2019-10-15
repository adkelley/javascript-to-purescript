# A curated collection of monoids and their uses

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 9** *in the series* **Make the leap from JavaScript to PureScript**. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 8](https://github.com/adkelley/javascript-to-purescript/tree/master/tut08) | [Tutorial 10 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10) [>> Tutorial 25](https://github.com/adkelley/javascript-to-purescript/tree/master/tut25)

Welcome to Tutorial 9 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  In this tutorial, we're going to break the topic of monoids wide open by increasing our vocabulary and showing how to put them to good use in production.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley)

## Time for a quick recap
In the last tutorial, we learned that a `monoid` is a `semigroup` with an `identity element`.  Let's deconstruct this sentence so that the definition is clear.  A `semigroup` is an algebraic structure with a binary operation that satisfies the associativity law.  For example, addition is a binary operation that is associative.  Because, when you add a set of numbers the result is the same regardless of how you group them, e.g., 1 + (2 + 3) = (1 + 2) + 3 = 6.

In PureScript, the binary operation for a semigroup that satisfies the associative property is called `append`, whose infix operator is `<>`.   I like to think of the `append` method as smashing two or more elements together to produce a single value.  You can construct semigroups by declaring the type(s) that belong to this semigroup together with its append operation.  Sticking with addition as our canonical example, and using Purescript's `Data.Monoid.Additive` we get:
```haskell
newtype Additive a = Additive a

instance semigroupAdditive :: Semiring a => Semigroup (Additive a) where
  (Additive a) <> (Additive b)  = Additive (a + b)
```
So what are the types that belong to `Additive`?  Well, the constraint above says that the type `a` must belong to the `Semiring` class.  It restricts the value `a` to be of type `Number`, `Int`, `Unit`, and..., don't forget, functions that return a `Semiring`.

Now that we have defined `semigroup`, we've almost got our `monoid` definition in the bag. All that is left is to explain is the `identity element`.  This element is a neutral value, such that whenever we append one or more elements to it, we get back those elements.  For addition, the identity element is `zero`, because `1 + 2 + 0 = 1 + 2,  2 + 3 + 0 = 2 + 3`, etc.  In PureScript, we use `mempty` (monoid empty) to reference the identity element of a monoid.

At last, we have the two parts necessary to declare our `Additive` monoid:

```haskell
newtype Additive a = Additive a

instance semigroupAdditive :: Semiring a => Semigroup (Additive a) where
  (Additive a) <> (Additive b)  = Additive (a + b)

instance monoidAdditive :: Semiring a => Monoid (Additive a) where
  mempty = Additive zero
```

Also, be aware that most, but not all, semigroups are monoids.  For example, in [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06) I introduced `First`, whose append method takes the `First` element while ignoring the rest.

```haskell
newtype First a = First a

instance Semigroup (First a) where
  a <> _ = a
```
But what if the first element is an empty array or list?  Well, that will just blow up in our faces because we don't have any value to return as our first argument.  Moreover, it won't even compile in PureScript, assuming we've defined the array in our code.  Fortunately, in [Tutorial 7](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07), we found a way to make `First` a monoid by using the `Maybe` constructor where `Nothing` becomes the identity element (`mempty`)
```haskell
newtype First a = First (Maybe a)

instance semigroupFirst :: Semigroup (First a) where
  append first@(First (Just _)) _ = first
  append _ second = second

instance monoidFirst :: Monoid (First a) where
  mempty = First Nothing
```
Did you catch the `first@` syntax?  When pattern matching, the @ sign means “Read As”, so `first` now refers to the entire expression `(First (Just a) )`.  So, instead of retyping a long `(First (Just a) )` on the right-hand side, I can type `first`.  This shortener is also handy when passing the expression to a function.

## Meet the monoids
In the last tutorial, I kept our list of monoids limited to three because it helped us to stay focused on the "what are monoids and what do they do?" part of learning.  This tutorial is all about introducing you to the wide variety of monoids available in functional programming, along with examples of their usage.  I'll again cover `Additive`, `Conj`,  and `First` for good measure. Then I will add `Disj`, `Multiplicative`, `Max`, `Min`, and `Tuple` to the family.  There are much more, but this will get you started, and you might just come up with a few of your own (did anyone say `Last`?).

By now, I hope you have watched Brian's [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses).  Sometimes the names are different, so I've created a table below which shows the name of the monoid in JavaScript (from Brian's video) and its equivalent in PureScript.

| JavaScript 	| PureScript     	|
|------------	|----------------	|
| Sum        	| Additive       	|
| Product    	| Multiplicative 	|
| Any        	| Disj           	|
| All        	| Conj           	|
| Max        	| Max            	|
| Min        	| Min            	|
| First      	| First<sup>1</sup>         	|
| Pair      	| Tuple         	|

<sup>1</sup>As discussed above, `First` in PureScript is different than Brian's implementation of `First` in JavaScript.  PureScript's implementation uses the `Maybe` constructor to promote it to a monoid using `Nothing` as the identity element.

### Shortening map and foldr to foldMap
I mentioned in Tutorial 8 that I would show you how to reduce the syntax needed to map a list or array of elements to a monoid and append them using foldr.  If you recall, we used the following pattern throughout the last tutorial:
```haskell
foldr (<>) mempty $ map Additive [1, 2, 3]
```
This pattern is soooooo prevalent in FP, so pay close attention. We map a monoid constructor (e.g., `Additive`) to elements contained in a foldable structure (e.g.,`Array`) and reduce them to a single monoid by appending them to the identity element `mempty`.

Whenever you see an overly complicated expression like the one above then, you may have a 'code smell' that's in need of a deodorizer!  Well, thankfully there is a freshener for this expression, and it is called `foldMap`.  Let's take a look at the type declaration:
```haskell
foldMap ::  forall a m.  Monoid m => (a -> m) -> f a -> m
```
It means what I stated above - for all values of type `a` when given a monoid `m`, you can map values wrapped in a foldable structure `f` into monoids.  Then, safely fold them using `append` into a single monoid using the identity element Now
```haskell
foldr (<>) mempty $ map Additive [1, 2, 3]
```
becomes
```haskell
foldMap Additive [1, 2, 3]
```

Very nice and concise!  Now let's get started on those monoids:

```haskell
mempty :: Additive Int -- (Additive 0)
foldMap Additive [1, 2, 3]  -- (Additive 6)
```
The first line above logs the identity element (Additive 0), while the next line records the result (Additive 6) of reducing the array to a single monoid.

Now, using the same format as above:
```haskell
mempty :: Multiplicative Int -- (Multiplicative 1)
foldMap Multiplicative [1, 2, 3] -- (Multiplicative 6)
```
```haskell
mempty :: Disj Boolean -- (Disj false)
foldMap Disj [false, false, true] -- (Disj true)
```
```haskell
mempty :: Conj Boolean -- (Conj true)
foldMap Conj [true, true, false]  -- (Conj false)
```
```haskell
mempty :: Max Int -- (Max -2147483648)
foldMap Max [1, 2, 3] -- (Max 3)
```
```haskell
mempty :: Min Int -- (Min 2147483647)
foldMap Min [1, 2, 3] -- (Min 1)
```
As for `Max` and `Min`, a further explanation of their respective identity elements is in order.  For `Max`, the neutral element is the minimum safe `Int`, which is -2147483648.  Why, because `Int` is a 32-bit signed binary integer, so this is the smallest value representable.  And, vice-versa, for `Min`, the neutral element is the maximum safe `Int`, which is 2147483647.

## Monoids gone wild!

Well, so far so good.  We've seen several popular monoids along with their identity elements.  In the next set of examples, we'll take it up a notch by showing how useful these monoids can be in production.

### You've got stats!
```haskell
type Stats =
  { page :: String
  , views :: Maybe Int
  }

badStats :: Array Stats
badStats =
  [ { page: "Home",  views: (Just 1) }
  , { page: "Blog",  views: Nothing  }
  , { page: "About", views: (Just 10)}
  ]

fromNothing :: forall a. Maybe a -> Either String a
fromNothing (Just x) = Right x
fromNothing _ = Left "Nothing"

foldMap (Additive <<< fromNothing <<< _.views) badStats
```
Working from the top down in the example above, we have a [Record](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06) of type `Stats` that we use to compute the number of views for each page on our website. We've also added a safety mechanism by using the `Maybe` constructor with our `views` field.  In case of some unforeseen event, like the database is down, we can assign `views` to `Nothing` and handle the error downstream.  Next, we store the stats in an array (in this case `badStats`), and we'll later use this container to fold the views and derive the total for all the web pages.

 So how to deal with the possibility of views becoming `Nothing` due to a technical error? Well, that is the purpose of `fromNothing`, which takes a `Maybe` value and turns it into an `Either` type.  Why is it necessary? Well if you recall from [Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03), a `Left` value is a good way to stop a `fold` operation right in its tracks.  In our `foldMap` expression, we are composing three functions `( Additive ( fromNothing ( _.views )))` that define the `Map` part of our `foldMap`. Remember that `_.views` is our record accessor function. Using `badStats` as our test array, as soon as `foldMap` encounters `Additive (Left "Nothing")` then our append operation stops and `foldMap` returns with the error; allowing us to deal with it as we please.

### Find me an agent
In his JavaScript [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses) Brian showed us how to combine `First` and `Either` to find the first element in a list that satisfies a predicate.  As you might imagine, this is a common task, so PureScript has a similar version of `find` in the [Data.Foldable](https://pursuit.purescript.org/packages/purescript-foldable-traversable/3.4.0/docs/Data.Foldable#v:find) module. Note that, instead of `Either`, `Data.Foldable.find` uses the `Maybe` constructor to return the first element satisfying the predicate (i.e., `Just a`) or `Nothing`.  

You won't learn anything if I use `Data.Foldable.find`, so let's construct our version `find` using the constructors we have at hand, namely `foldMap` and `First`.

```haskell
find ∷ ∀ c a. Foldable c ⇒ (a → Boolean) → c a → Maybe a
find f = unwrap <<< foldMap (First <<< maybeBool f)

find (_ > 4) [3, 4, 5, 6, 7] -- (Just 5)
```

Notice `find` works with any `Foldable` data structure, such as an `Array` or `List`. It illustrates why polymorphism is your friend; especially for reusable functions, so use it whenever possible. Also, if you like, start taking advantage of the ability to use Unicode characters in your code, i.e., `∀` instead of `forall`.  You can use them in names, operators, and syntax, and you will find more information on this topic [here](https://github.com/paf31/24-days-of-purescript-2016/blob/master/2.markdown).  I'm also using point free programming (covered in Tutorial 5) above by dropping the xs from below:

 ```haskell
 find f xs = unwrap <<< foldMap (First <<< maybeBool f) xs`
 ```

 Finally, `maybeBool` does what it says - it tests a value against a predicate `f` and returns `(Just a)` or `Nothing` depending on whether the result of `f` is `true` or `false`.

### Filtering on multiple predicates
Amongst Brian's curated examples of monoids, this next one is my favorite.  We've got two predicates, `hasVowels` and `longWord`, and we want to filter a list of strings down to just those that satisfy both predicates.  Here's how we solve it:
```haskell
regexFlags :: RegexFlagsRec
regexFlags = { global: true, ignoreCase: true
             , multiline: false, sticky: false
             , unicode: false
             }

vowelsRegex :: Regex
vowelsRegex =
  unsafePartial
    case regex "[aeiou]" (RegexFlags regexFlags) of
      Right r -> r

hasVowels :: String -> Boolean
hasVowels s =
  case match vowelsRegex s of
    Just _ -> true
    _      -> false

longWord :: String -> Boolean
longWord s = length s > 4

multiple ∷ ∀ m a b c. Foldable c ⇒ Monoid m ⇒ (a -> m)
     -> c (b -> a)
     -> b
     -> m
multiple m = foldMap (compose m)

filter (unwrap <<< multiple Conj [hasVowels, longWord]) ["gym", "bird", "lilac"]
filter (unwrap <<< multiple Disj [hasVowels, longWord]) ["gym", "bird", "lilac"]
```
Let's again start from the top and work our way down.  We're going to evaluate a regular expression in `hasVowels`, so we start by setting our regex flags using `regexFlags`. In this case, I want to set two flags to `true`, so we'll have to do it the hard way with a full blown record setter.  Next, here comes `vowelsRegex` which defines our regular expression for searching for words with vowels.  Note we covered regular expressions in PureScript in [Tutorial 5](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05).  So if you're having trouble comprehending what's going on, then please look there.  As a hint, `unsafePartial` is required because I haven't covered the case of a poorly formed regular expression.  But here, I know it is correct, and so covering this case is unnecessary.

Next, `hasVowels` will test the words against the regular expression, unwrapping the `Maybe` constructor and returning a boolean. And yes, I agree that dealing with regular expressions in PureScript can seem overly verbose compared to JavaScript. But it's all about avoiding mishaps that will burn you at runtime.

We'll skip over `longWord` since that should be self-explanatory.  Up next is my favorite function in the example, `multiple`.  Brian's implementation (i.e., `both`), is limited to two predicates. I was a little more ambitious with `multiple` by allowing multiple predicates, and polymorphic monoids & foldable structures - oh my! We have our familiar `foldMap` expression with the mapping function `compose m`.  "What's this?" you ask?  Well `compose` is located in the prelude package and it's the function behind the operator alias `(<<<)`.  For the first filter operation, the composition is `( Conj ( hasVowels ( longWord ( w )))` where `w` is each word in the `ws` array `["gym", "bird", "lilac"]`.  I'm also using `point-free` again by dropping the `ws`.

Finally, we've reached our filter expression.  The only thing worth mentioning here is that `filter` requires a boolean predicate, so we unwrap the boolean value from the monoid (e.g., `Conj`) by composing `multiple` with `unwrap`.  The first filter will result in `["lilac"]`, while the second uses the `Disj` monoid to return `["bird", "lilac"]`.

### And then there was Tuple

With just `Tuple` left to cover, we've now reached the end of our adventure in 'Monoids in the wild!'. A tuple is a data structure that allows you to pass around multiple values contained within a single type constructor.  For example, a two-tuple or pair is a tuple that contains two values, and the types of those values can be the same or different.  For example, it's perfectly acceptable to have `Tuple 1 false`. Here is the relevant subset of the PureScript declaration for `Tuple`:
```haskell
data Tuple a b = Tuple a b

instance semigroupTuple :: (Semigroup a, Semigroup b) => Semigroup (Tuple a b) where
  append (Tuple a1 b1) (Tuple a2 b2) = Tuple (a1 <> a2) (b1 <> b2)

instance monoidTuple :: (Monoid a, Monoid b) => Monoid (Tuple a b) where
  mempty = Tuple mempty mempty
```
To compute the sum of an array of tuples of integers, we turn to our now familiar `foldMap` using the `Additive` monoid as our map function:
```haskell
foldMap Additive [(Tuple 1 2), (Tuple 3 4)] -- (Additive (Tuple 4 6))
```
Conjunction and Disjunction are similar too:
```haskell
foldMap Conj [(Tuple true false), (Tuple true false)] -- (Additive (Tuple true false))
foldMap Disj [(Tuple true false), (Tuple false true)]  -- (Additive (Tuple true true))
```
Here's one approach to mapping and folding over an array of tuples with values that are of different types:
```haskell
toSumAll :: Tuple Int Boolean -> Tuple (Additive Int) (Conj Boolean)
toSumAll (Tuple a b) = Tuple (Additive a) (Conj b)

fromSumAll :: Tuple (Additive Int) (Conj Boolean) -> Tuple Int Boolean
fromSumAll (Tuple (Additive a) (Conj b)) = Tuple a b

fromSumAll $ foldMap toSumAll [(Tuple 1 false), (Tuple 2 false)]
```
Perhaps this is not the most elegant solution, but it serves as a good example of how pattern matching can save your skin time and again.

## Summary
In this tutorial, we expanded our vocabulary of monoids to include `Multiplicative`, `Disj`, `Max`, `Min` and `Tuple`. We also explored a few examples of how to use them in practice.  We found that `foldMap` gives us some syntax sugar sweetness when you need to map and reduce over a foldable structure of values. Finally, I would be negligent if I didn't mention that arrays, lists, and strings are monoids too.  Each has an identity element, and the append method satisfies the associative law. But I'll leave as an exercise for the reader to determine the identity element for each.  

Once again, whether or not you're finding these tutorials helpful in making the leap from JavaScript to PureScript then give me clap, drop me a comment, or post a tweet. My twitter handle is [@adkelley](https://twitter.com/adkelley).  I believe any feedback is good feedback and helpful toward making these tutorials better in the future.  Till next time.

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut08) **Tutorials** [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
