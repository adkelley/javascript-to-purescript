# Ensure failsafe combination using monoids

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 8** *in the series* **Make the leap from JavaScript to PureScript**. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript/blob/Master/README.md) [< Tutorial 7](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07) | [Tutorial 09 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09) [>> Tutorial 25](https://github.com/adkelley/javascript-to-purescript/tree/master/tut25)

Welcome to Tutorial 8 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  In this tutorial, we define and promote our semigroups from [Tutorial 7](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07) to monoids.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-failsafe-combination-using-monoids) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better that you understand its implementation in the comfort of JavaScript.

The markdown and all code examples for this tutorial are located on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut08).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut08).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley)

## Semigroups - you deserve a promotion!
Recall from [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06) and [Tutorial 7](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07)  that a semigroup is a type that has an append method.  For example, we covered the `Additive`, & `Conj` semigroups and their append methods are addition and [logical conjunction](https://en.wikipedia.org/wiki/Logical_conjunction) respectively.  The `First` semigroup was even more interesting because its append method returns the first non-Nothing value.   

Let's look at `Additive` from the module [Data.Monoid.Additive](https://pursuit.purescript.org/packages/purescript-monoid/3.1.0/docs/Data.Monoid.Additive). The append method is an addition, where:

```haskell
Additive x <> Additive y == Additive (x + y)
```
You may recall that we used it in Tutorial 7 to help merge Nico’s game accounts by adding her `points` from each account.  

There is another interesting property with `Additive` that manifests itself when you add an element to zero.  If we have Additive (1 + 0), we get back (Additive 1), Additive (2 + 0) returns (Additive 2), and so on.  Thus anything plus zero will return that thing.  Here, zero is the called the identity or neutral element for `Additive`, meaning whenever we append one or more numbers with zero, we get back their sum.  You'll see why this is important shortly.  But first, let's introduce the identity elements for the other semigroups covered in Tutorial 7.

### Determining the identity element
Consider `Conj` from [Data.Monoid.Conj](https://pursuit.purescript.org/packages/purescript-monoid/3.1.0/docs/Data.Monoid.Conj), whose append method is logical conjunction:

```haskell
Conj x <> Conj y == Conj (x && y)
```
We used it in Tutorial 7 to append the `hasPaid` values (either true or false) from Nico’s three accounts.  So what is `Conj`'s identity element?   If we have:
```
true && true == true
false && false == false
true && false == false
false && true == false
```

So it appears that `true` is the identity element or neutral value for `Conj`.

Finally, let's look at `First` from [Data.Maybe.First](https://pursuit.purescript.org/packages/purescript-maybe/3.0.0/docs/Data.Maybe.First), whose append operation returns the first (left-most) non-Nothing value.  We used `First` in Tutorial 7 to take the first non-nothing name from Nico’s three accounts.  For example, `Nothing  <> (Just Nico) ` is `(Just Nico)` and `(Just Nico) <> Nothing ` is  `Just Nico`.  So it appears that the identity element for `First` is `Nothing`.

In PureScript, `mempty` refers to the identity element, like the `0`, `true`, and `Nothing` values we've seen so far.  You can find the `mempty` declaration for each semigroup in their respective modules, e.g., `Data.Monoid.Additive`.  So

```haskell
Additive x <> Additive y == Additive (x + y)
mempty :: Additive _ == Additive zero

Conj x <> Conj y == Conj (x && y)
mempty :: Conj _ == Conj true
```
Now, you might have wondered from the last tutorial, "why doesn't PureScript name these modules `Data.Semigroup.XX`?"  Well, that is the main subject of this tutorial - in addition to being semigroups, `Additive`, `Conj`, and `First` are also monoids because they have an identity element.

### An informal definition of a monoid
Monoids are semigroups with an identity element.  That's it - really!  That is all you need to know from a programmers perspective.  Like semigroups, monoids come from abstract algebra.  Now I said it in Tutorial 6, and I'll say it here again - don't let this, or any other mathematical name, scare you from learning functional programming.  If we keep the names (e.g., monoid), then we benefit from a whole lot of information derived from the mathematics, namely the types and their laws!

For a more formal definition of this and other algebraic terms, one of the most approachable tutorial series for functional programmers is from [Bartosz Milewski](https://bartoszmilewski.com).  So, after you’ve run through my code examples below, and made some of your own, I encourage you to carve out some time each week to explore what he has to say on these topics.

### Not every semigroup gets a promotion
Are there semigroups that don't have an identity element?  You bet!  In [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06), I used my own, custom implementation of `First`, instead of [Data.Maybe.First](https://pursuit.purescript.org/packages/purescript-maybe/3.0.0/docs/Data.Maybe.First).  My `First` semigroup in Tutorial 6 ignored every element within an append operation, except for the first argument, returning that element regardless.  But what if the first argument is an empty array or list?  Well, that will just blow up in our faces because we don't have any value to return as our first argument.

If you are skeptical (and you should be), then go back to the code in [Tutorial 6](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06/src/Main.purs) and add the following to the `main` function.  It's an attempt to log the result of appending an empty array with a non-empty one.  You'll find that it won't even compile.
```haskell
logShow $ (First null) <> (First [1])
```
So, sadly, `First` from Tutorial 6 stays a semigroup because it doesn't have an identity element.  The upside is, in contrast to JavaScript, that you are finding this out at compile time instead of run time where the stakes are much higher.

But, what about `First` from the module `Data.Maybe.First`? You may recall I used this version in Tutorial 7.  You will find that the code below compiles and returns `(First (Just [1]))`.  
```haskell
logShow $ (First Nothing) <> (First (Just [1]))
```
Because this implementation of `First` has the identity element `Nothing`, it just earned its monoid badge - congratulations `First`!

##   Monoid usage and examples
Monoids are useful because you can perform 'safe' operations with them.  For example, let's say our code returns an empty list of the `Additive` type. Then, instead of blowing up, the value returned will be zero.  In summary, for the three monoids we've covered so far, `mempty` returns the following:

```haskell
  logShow (mempty :: Additive Int) -- (Additive 0)
  logShow (mempty :: Conj Boolean) -- (Conj true)
  logShow (mempty :: First Int) -- First (Nothing)
```

Note the inline type assignment (e.g., `mempty :: Additive Int`) within our PureScript code. It is a handy feature for declaring the type of generic type constructs such as `mempty`.

### Code examples
We'll keep the code light and easy in this tutorial; giving a few examples of appending the identity element (i.e., `mempty`) to the monoids `Additive`, `Conj`, and `First`.  In the next tutorial, we'll add several more monoids to our tool belt and give examples of how you can take advantage of them in your code.

```haskell
-- logs (Additive 6)
logShow $ foldr (<>) mempty $ map Additive [1, 2, 3]
-- logs (Conj false)  
logShow $ foldr (<>) mempty $ Conj <$> [true, true, false]
-- logs First ((Just 1))
logShow $ foldr (<>) mempty $ First <$> [Nothing, Just 1, Just 2]
```

### Using map to construct semigroups
In the examples above, to keep things 'DRY' (i.e., Don't Repeat Yourself), I am leveraging our old friend `map` to take an array of concrete types (e.g., Int, Number, etc.)  and turn them into an array of semigroups before folding them.  In the second and third examples, I'm using map's infix operator `<$>`.  You'll see `<$>` often, so it is important you are aware of this idiomatic alternative.  In the next tutorial, I’ll show you how to shorten this expression even further.

If we don't use `map` then the first example above would look like this:

```haskell
-- (Additive 6)
logShow $ foldr (<>) mempty [Additive 1, Additive 2, Additive 3]
```

So `map` is perfect for eliminating this repeated pattern.  Why does this work?  Because `Additive`, `Conj`, and `First` are type constructors, and therefore they are functions `(a -> b)`, just like the `Either` and `Maybe` constructors we have seen before. Type constructors are new types that we compose from old ones.  For example, `Int` becomes `Additive Int`.  

As shown below, we can use a type constructor as our first argument `(a -> b) ` in the map expression, with the second argument being a foldable structure `f` of elements `a`, and returning the same structure `f` of new elements `b`.

```haskell
map :: forall a b. (a -> b) -> f a -> f b
```
Here is a concrete declaration of `map` using `Array` with the `Additive` monoid:
```haskell
map :: (Int -> Additive Int) -> Array Int -> Array (Additive Int)
```

## Summary
In this tutorial, we learned that semigroups could be promoted to monoids if they have an identity element.  An identity element in PureScript is the value `mempty`, where  
```haskell
forall x. mempty <> x = x <> mempty = x
```
The above means that if you append a monoid with its identity element, then you get back the monoid with that element. The value of the identity element, `mempty` will depend on the monoid.  For example, in the case of the `Additive` monoid, the value of `mempty` is zero.

In the next tutorial, we will look at several new monoids and how to advantage of them in our code.  Finally, if you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My twitter handle is [@adkelley](twitter.com/adkelley).  Till then!

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut07) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
