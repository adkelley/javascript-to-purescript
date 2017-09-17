# Unbox types with foldMap

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 9** *in the series* **Make the leap from JavaScript to PureScript**. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 9](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09)

Welcome to Tutorial 10 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  In this tutorial, we're going to break the topic of monoids wide open by increasing our vocabulary and showing how to put them to good use in production.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley)

## Introduction 
Good news!  If you have been following Brian's tutorials (and you should be), we're ahead on the topics that we need to cover.  In our case, it was more appropriate to introduce `foldMap` in [Tutorial9](https://github.com/adkelley/javascript-to-purescript/tut09).  So we'll take advantage of this opportunity of being ahead to further dive into `foldMap`, while adding a few more monoids to our arsenal. Then we'll wrap up by introducing two popular testing libraries in PureScript, [Test Unit](https://github.com/bodil/purescript-test-unit) and [Spec](http://purescript-spec.wickstrom.tech).

## Take a deep dive into foldMap
In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tut09/) we learned that `foldMap` essentially combines `foldr` and `map` into one function.  Why?  Well given that the pattern of mapping and right folding is so prevalent, our FP overlords were kind enough to combine them into one expression (just saying).  We used it to append an array or list of monoids into a single monoid using the identity value for that monoid.

Let's see why `foldMap` is equivalent to `foldr` and `map` by taking a look at the type signatures.  Note that for both the `foldr` and `map` type declarations below, `f` is a foldable structure, such as an `Array` or `List`.  First up is the `map` function.

```haskell
map ::  ∀ a b. (a -> b) -> f a -> f b
```
In the `map` type declaration above, the function (a -> b) maps each value `a` within `f` to a `b` within `f`.  For instance, using our canonical `Additive` monoid example, with `Int` as our type for `a`, we create the following code example.  Note I've created a couple of type aliases which substitute `Additive Int` and `Array` for `Sum` and `A` respectively.  This substitution will help keep the type declarations all on one line.

```haskell
type Sum    = Additive Int
type A      = Array

map    ::   (a   -> b )   -> f a   -> f b
mapSum ::   (Int -> Sum)  -> A Int -> A Sum
mapSum fn = map fn

mapSum Additive [1, 2, 3] = [Additive 1, Additive 2, Additive 3] 
```

Now, let’s take a look at right fold (i.e., `foldr`).
```haskell
foldr :: ∀ a b. (a -> b -> b) -> b -> f a -> b
```
With `foldr` the function (a -> b -> b) takes a function of two arguments `a` and `b` and transforms them into a `b`.  Keeping with the `Additive` monoid as our canonical example, we'll use `append` for this function, recalling that its infix operator is `(<>)`.  Now, if we're going to `right fold` an array of monoids, we also need our identity value `b` to append to the last element in our array.  So we use `Additive 0` for this value.

```haskell
type Sum    = Additive Int
type A      = Array

foldr    ::  (a -> b -> b)        -> b   -> f a   -> b
foldrSum ::  (Sum -> Sum -> Sum)  -> Sum -> A Sum -> Sum
foldrSum fn identity = foldr fn identity

foldrSum (<>)  (Additive 0)  $ mapSum Additive [1, 2, 3] = Additive 6
```

Finally, we're ready to put all the pieces together to show that `foldMap` is essentially the combination of `map` and `foldr` for monoids:

```haskell
type Sum = Additive Int
type A   = Array

foldMap    ::  forall a m
            .  Monoid m 
           =>  (a -> m)      -> f a   -> m
foldMapSum ::  (Int -> Sum)  -> A Int -> Sum
foldMapSum fn = foldMap fn

foldMapSum Additive [1, 2, 3]  = Additive 6
```

Here `(a -> m)` is the append function and the identity value is dermined by the monoid `m` that we send into `foldMap`.

## More monoids, please
Dual, Last, Ordering, etc.

## Ablien monoid
Abelian monoid is a monoid that is also commutative, like addition and multiplication (but not lists or strings, for which order is significant). You can also just say commutative monoid or, if you prefer, not talk about them at all. But do spread the word about monoids.
## Group
## Testing in PureScript
[PureScript Spec](http://purescript-spec.wickstrom.tech)
## Quickcheck
## Browserify, using code in an HTML document

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
