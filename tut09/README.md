# A curated collection of monoids and their uses

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 9** *in the series* **Make the leap from JavaScript to PureScript**. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 7](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07)

Welcome to Tutorial 9 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  In this tutorial, we XX.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better that you understand its implementation in the comfort of JavaScript.

The markdown and all code examples for this tutorial are located on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley)

## Time for a quick recap
In the last tutorial, we learned that a `monoid` is a `semigroup` with an `identity element`.  Let's deconstruct this sentence so that the definition is clear. A `semigroup` is a type together with a binary operation, append (`(<>) ` in PureScript) that satisfies the associativity law.  A value belongs to a `semigroup` if you can append it to another value of the same type.  The canonical example is the `String` type; e.g.,  `"Hello, " <> "World" = "Hello, World"`.  

An `identity element` is a neutral value, such that whenever we append one or more elements to it, we get back the concatenation of those elements.  For addition, the identity element is `0`; `1 + 0 = 1,  2 + 0 = 2,  3 + 0 = 3`, etc.  In PureScript, we use `mempty` to reference the identity element of a monoid.

You will find the methods `append`, `reduce`, `concatenate` are all used interchangeably in functional programming.  I like to think of it as smashing two or more elements together to produce a single value.  Also, be aware that most, but not all, semigroups are monoids.  For example, in Tutorial 6 I introduced `First`, whose append method takes the `First` element of the elements.

```haskell
newtype First a = First a
instance Semigroup (First a) where
  a <> _ = a
```
But what if the first element is an empty array or list?  Well, that will just blow up in our faces because we don't have any value to return as our first argument.  Fortunately, in Tutorial 7, we found a way to make `First` a monoid by using the `Maybe` constructor where `Nothing` becomes the identity element (`mempty`)
```haskell
newtype First a = First (Maybe a)
instance Monoid (First a)  where
   append first@(First (Just a) )  _ = first
   append _ <> second = second
   mempty = First Nothing
```
Did you catch the `first@` syntax?  When pattern matching, `first` now refers to the entire type `(First (Just a) )`.  So, instead of retyping a long `(First (Just a) )` on the right-hand side, I type `first`.  That can also be handy when passing the type to a function.

## Meet the monoids
Till now we have kept our list of monoids limited to three because it helped us to stay focused on what monoids are and what they do.  This tutorial is all about introducing you to a wide variety of monoids already available in functional programming and examples of their usage.  I'll again cover `Additive`, `Conj`,  and `First` for good measure. Then I will add `Disj`, `Multiplicative`, `Max`, `Min`, and `Tuple` to the family.  There are much more, but this will get you started, and you might just come up with a few of your own.

### Shortening map and foldr to foldMap
I mentioned in Tutorial 8 that I would show you how to reduce the syntax needed to map a list or array of elements to a monoid and append them using foldr.  If you recall, we used the following pattern throughout that tutorial:
```haskell
foldr (<>) mempty $ map Additive [1, 2, 3]
```
Whenever you see a long and complicated expression (like the one above) that repeats multiple times, then you should suspect there's a 'code smell'!  I guarantee that you will use this pattern time and again in FP.  That is, map a monoid constructor (e.g., `Additive`)  to elements from an `Array` and reduce them to a single monoid value using `mempty`.  Well, there's a method for that, and it is called `foldMap`, which uses `foldr`, `map`, and `mempty` under the hood.  

Let's take a look at the type declaration:
```haskell
foldMap ::  forall a m.  Monoid m => (a -> m) -> f a -> m
```
It means that for all values of type `a`  then given a monoid constructor `m`, you can turn those values (wrapped in a foldable structure `f`) into monoids and safely append them into a single monoid using the identity element. Thus
```haskell
foldr (<>) mempty $ map Additive [1, 2, 3]
```
becomes
```haskell
foldMap Additive [1, 2, 3]
```
Nice!  Now that's out of the way, let's have a look those monoids.

## Monoid examples
By now, I hope you have looked at Brian's [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses).  I've created a table below which shows the name of the monoid in JavaScript (from Brian's video) and its equivalent name in PureScript.

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

<sup>1</sup>As discussed above, `First` in PureScript is different than Brian's implementation of `First` in JavaScript.  The PureScript implementation uses the `Maybe` constructor to promote it to a monoid using `Nothing` as the identity element.

Now let's get started on these monoids:

```haskell
logShow $ mempty :: Additive Int -- (Additive 0)
logShow $ foldMap Additive [1, 2, 3]  -- (Additive 6)
```
The first line above logs the identity element (Additive 0), while the next line records the result (Additive 6) of reducing the array to a single monoid.  I will use the same approach for the remainder of the examples below

Now, using the same format as above:
```haskell
logShow $ mempty :: Multiplicative Int -- (Multiplicative 1)
logShow $ foldMap Multiplicative [1, 2, 3] -- (Multiplicative 6)
```
```haskell
logShow $ mempty :: Disj Boolean -- (Disj false)
logShow $ foldMap Disj [false, false, true] -- (Disj true)
```
```haskell
logShow $ mempty :: Conj Boolean -- (Conj true)
logShow $ foldMap Conj [true, true, true]  -- (Conj true)
```
```haskell
logShow $ mempty :: Max Int -- (Max -2147483648)
logShow $ foldMap Max [1, 2, 3] -- (Max 3)
```
```haskell
logShow $ mempty :: Min Int -- (Min 2147483647)
logShow $ foldMap Min [1, 2, 3] -- (Min 1)
```
As for `Max` and `Min`, a further explanation of their resprective identity elements is in order.  For `Max`, the neutral element is the minimum safe `Int`, which is -2147483648.  Why, because `Int` is a 32-bit signed binary integer, so this is the smallest value representable.  Thus, if we `foldMap` `Max` on an empty array, the return value will be `mempty` == -2147483648.  And, vice-versa, for `Min`, the neutral element is the maximum safe `Int`, which is 2147483647.  So again, if we `foldMap` `Min` on an empty array, the return value will be `mempty` == 2147483647.  
