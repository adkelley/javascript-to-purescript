# You've been using Functors!

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 14** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 13](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13) | [Tutorial 15 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15) [>> Tutorial 27](https://github.com/adkelley/javascript-to-purescript/tree/master/tut27)


Welcome to Tutorial 14 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we are going to explore a common and useful abstraction within functional programming - Functors.  Yes, at first blush, you might think that that functors are a scary, mathematical term indeed.  However, as the headline suggests, we've been using functors all along - I just never called them out.  They are incredibly useful and serve as a basis for future abstractions covered later in this series; including applicatives and monads.  By understanding functors and their laws, I guarantee they will serve you well throughout your functional programming adventures.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-you-ve-been-using-functors) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Definition of a Functor
The definition of a Functor is straightforward - it is any type constructor that supports a map method. That’s all - tutorial over!  Oh, wait - a functor also obeys a few laws which we'll cover shortly.  Unless you've studied category theory, then perhaps you've never heard of the term Functor before.  In mathematics, it is used to describe a mapping between categories. Similarly, in functional programming, we use it to describe the ability to perform a map operation over some type constructor. In our case, a category is a type argument.  For instance, let's take a moment to go back and review an example [Tutorial 10](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  In that tutorial,  I introduced the type signature of the `map` function:

```haskell
  map :: ∀ a b. (a → b) → f a → f b
```

One way of interpreting this function is that the `f` type constructor must be a functor because an instance of the `map` operation exists.  You'll find that almost all type constructors are functors; the canonical example being a list.  However, there are exceptions, such as a binary search tree.  You cannot freely substitute the values in a binary search tree because the substitution might change the ordering.  Another common interpretation is that an ordinary functor `f` is a "producer of output" that can have its type adapted. In the above type signature, we are adapting the output to become type `b`.  Keep this interpretation in mind as we continue on.

### Functors aren't always 'containery' type constructors!
It's a common misconception that only containers (e.g., lists) can be functors.  As a counter-example, consider the function type constructor `((→ ) r) = r → b`, which takes an input of type `r` and produces an output of type `b`.  With the help of function composition, we can create an instance of `map` that adapts the output to become type `b`. Therefore function arrows are functors too!

```haskell
-- | map == compose for function arrows
instance functorFn :: Functor ((→) r) where
  map f g = f <<< g 
```
It's worth noting that function composition allows us to change the output type from an `a` to type `b`. However, we aren't able to change the input type.  This inability is a limitation of an ordinary Functor and it speaks to my point earlier that ordinary functors are "producers of output" that can have its type adapted.  But there is a way to change the input type, making a functor become a "consumer of input".  Keep this point also in mind when we explore the topic of `Contravariant Functors` in the last section.  First, let's have a look at an ordinary Functor example.

### Ordinary Functor
I mentioned we've been using functors all along, so it seems appropriate to refer back to an example in a previous tutorial.  Using `Additive Int`  from [Tutorial 10](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10), I've aligned the type signature of `map_` with `map` to make the type arguments easy to follow.  Here we are mapping `Sum` over the functor `List`  containing integers to get another list of integers that are wrapped individually with `Sum`.  Thus, we adapt our list of `a`s to get a list `b`s, preserving the functor.
 
```haskell
type Sum = Additive Int

map  :: (a    -> b  ) -> f    a   -> f    b
map_ :: (Int  -> Sum) -> List Int -> List Sum
map_ = map

-- | Returns (Sum 1 : Sum 2 : Sum 3 : Nil)
map Sum (1 : 2 : 3 : Nil)
```

## Functor Laws
Now, what would a Functor be without laws for us to leverage in our code? Fortunately, they're simple to remember.  The first law of functors is one that preserves function composition while mapping.  That is: 

```haskell
--| First law of Functors: composition

-- | returns Box("RELS")
res1 :: Box String
res1 =
  Box "squirrels"
  # map (\str -> substrImpl 5 str)
  # map toUpperCase

-- | returns Box("RELS")
res2 :: Box String
res2 =
  Box "Squirrels"
  # map (\str -> toUpperCase $ substrImpl 5 str)
```

The functions `res1` and `res2` (given above) produce the same result, because the functor laws guarantee that mapping over a Functor `f` with the composition of two functions `fn1` and `fn2` (i.e., `fn2 <<< fn1`) is no different than mapping over the functor twice.  Moreover, function composition, as shown in `res2` is more efficient than `res1` because we map over our type constructor once only.  Just imagine if you have a list of thousands of objects, then you'll want to take advantage of the function composition law.

The second law is even simpler.  It shows that mapping over a Functor `f` with the identity function produces the same result as applying the identity function to the functor. As a reminder, the identity function takes an `x` and returns that `x`. Let's show the code:

```haskell
-- | Second law of Functors: identity

-- | returns Box("crayons")
res3 :: Box String
res3 =
  Box "crayons"
  # map identity

-- | Box("crayons")
res4 :: Box String
res4 =
  identity (Box "crayons")
```

In summary, for a type constructor to be a Functor, it must have a mapping operation, and it must preserve the identity and composition morphisms.  Here a morphism refers to a structure-preserving map from one type to another.  That's all there is to ordinary functors.  However, before we go, let's explore a couple more abstractions that belong to the family of functors.

## Bifunctors
Similar to a Functor, a Bifunctor is any type constructor `f` with a binary mapping operation (`bimap`) over not just one type argument, but two type arguments.  You can think of it as applying `map` over two independent channels.  The canonical example of a Bifunctor is a list or array of `Either` or `Tuple`.  Moreover, since we have two type arguments, that opens the opportunity for three types of map operations, `bimap`, `lmap` and `rmap`.  See my comments in the code example for further detail:

```haskell
--| map over a functor with two type arguments (e.g., Tuple)
class Bifunctor where
    bimap :: ∀ a b c d. (a → b) → (c → d) → f a c → f b d

-- | Map a function over the left type argument of a `Bifunctor`.
lmap :: ∀ f a b c. Bifunctor f => (a -> b) -> f a c -> f b c
lmap fn = bimap fn identity

-- | Map a function over the right type arguments of a `Bifunctor`.
rmap :: ∀ f a b c. Bifunctor f => (b -> c) -> f a b -> f a c
rmap fn = bimap identity fn
```

Like Functor, a Bifunctor obeys the Functor laws of composition and identity morphisms. Have a look at the code in my [tutorial repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14) where I demonstrate these laws. 

One interesting question is whether `map` can be used instead of `bimap` to map over a functor that has two type arguments.  Well, not if you want to change both `a & b` to `c & d` respectively - you'll need `bimap` for that.  However, if you want to apply (b → d), leaving the `a` type argument untouched, then you're all set.   However, for better readability, I suggest you use `Data.Bifunctor.rmap ` instead.  If you need to map the left argument, then use `Data.Bifunctor.lmap`.

## Contravariant functors
While Brian didn't cover a Contravariant Functor in his video, I thought this might be a good place to introduce it.  This is an advanced abstraction, taking me a good amount of time to understand and implement in practice.   If you don't get it the first or second time, then don't sweat it, because I've been in your shoes.  If you're new to functional programming, then feel free to skip this section, and come back to it later down the road.  Rest easy knowing that, compared to ordinary functors, contravariant functors have less applicability. 

Recall that I mentioned that with an ordinary functor, the mapping operation changes the resulting type only.  Moreover, recall the intuition that ordinary functors are a "producer of output values" that can have its type adapted (i.e., (a → b)).  However, what if we would like to transform our functor into a "consumer of input values" that can have their type adapted?  That is the intuition behind a *Contravariant* functor.   But first, let’s understand the difference between an ordinary functor (aka *Covariant*) and a *Contravariant* functor. 

### Covariant functors
Covariant functors are often called ordinary functors.  So far, the functor examples that I've covered have been *covariant*.  That is, there is a mapping operation over the type constructor that preserves the direction of the arrow.  So the 'co' in covariant means 'together' - where all the arrows in the type signature point to the right:
```haskell
class Functor f where
   map :: (a → b) → f a → f b
```
Again, a common intuition for a covariant functor is a "producer of output" that can have its type adapted.

### Contravariant

```haskell
class Contravariant f where
    cmap :: ∀ a b f. Contravariant f => (b → a) → f a → f b
```

As you might guess, `cmap` stands for *contravariant map*.  What's different from the covariant functor instance is that we have a `(b → a)` instead of a `(a → b)`.  Also, recognize that the identity and composition functor laws still apply:

```haskell
cmap identity = identity
cmap f <<< cmap g = cmap (g <<< f)
```

Coding examples to show these laws are an exercise left to the reader.

So how can we derive `(b → a)`, and what are contravariant functors good for?  Well, let's tackle the latter question first.  Say we have a predicate function `(a → Boolean)` which classifies integers as either positive or negative.

```haskell
negative :: Int → Boolean
negative x = x < 0 
``` 
Being a big believer in code reuse, we don't want to have to duplicate this function to support floating point numbers.  If we have a way of adapting our floating point input values to integers first, then we can apply this predicate function without any changes.  

So, we've seen one example of what contravariant functors are good for, but how do we know one when we see it?  Well, surprise, you've already seen one. Recall our "non-containery" function arrow `((→) r) = r → b` functor, with a mapping operation that is essentially function composition:
```haskell
-- | map == compose for function arrows
instance functorFn :: Functor ((→) r) where
    map f g = f <<< g 
```
However, as it stands, the ordering of the type parameters in `cmap` doesn't allow us to make an instance of this adaptation just yet.  But if we create a `newtype` then we're all set:

```haskell
newtype Predicate a  = Predicate (a → Boolean)
```
A Predicate type constructor determines the "truthiness" of a value `a` by returning a boolean of `true` or `false`.  

Now we can create an instance of  `cmap`  that takes a Predicate `p` and composes it with a function `g`. 

```haskell
instance contravariantPredicate :: Contravariant Predicate where
  cmap g (Predicate p) = Predicate (p <<< g)
```

### Contravariant example
With all the pieces in place, now let’s create a function `isNegative`, which returns a "thunk" of ` Predicate Number`.   Note that a "thunk" is a function with no arguments and whose evaluation is pending.

```haskell
negative :: Int → Boolean
negative x = x < 0

isNegative :: Predicate Number
isNegative = cmap (\x → floor x) (Predicate negative)
```

`(\x → floor x`) is our `g` function in `cmap` (see `cmap` instance) that is mapped over a floating point input value to transform it into an integer. Then, this is composed with `negative`  to form our `Predicate (\x → negative <<< floor x)`.  As it stands, `isNegative` is just a thunk, so if we want to evaluate it then we need one more function that I call `truthiness`:

```haskell
truthiness :: ∀ a. Predicate a → (a → Boolean)
truthiness (Predicate p) = p
```
Thanks to pattern matching, this is simple to express.   Finally, let's map over an array of negative and positive floating point values by applying the function `truthiness isNegative` to each value in the array.  Then we use an instance of `show` to log the array of booleans to the console:

```haskell
main = do
log $ "isNegative : " <> result where
   result = show $ map (truthiness isNegative) [1.3, (-1.5), (-2.6)]
```

## Summary

In this tutorial, we covered the topic of Functors;  an abstraction that we have been using throughout this series.  For a type constructor to be a Functor, it must have a mapping operation, and it must preserve the identity and composition morphisms.  Here a morphism refers to a structure-preserving map from one type to another.  We then explored the difference between a *covariant* Functor and *contravariant* Functor.  We found that covariant or ordinary functors are the most common type of functor, but there are good use cases for contravariant functors too.  The canonical example of a contravariant functor is a [Predicate](https://pursuit.purescript.org/packages/purescript-contravariant/4.0.0/docs/Data.Predicate#t:Predicate).  Finally, I've left an easter egg in my [code repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14), so be sure to check it out.  You'll find the references that I've listed below will help you to explore and understand this egg.

That's all for now. My next tutorial will explain how `pure` and `map` can be used to place a value into a Functor, regardless of the complexities of the type constructor. If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media. Thank you and till next time!

## Resources

* [A Gentle Introduction to Profunctors](https://www.youtube.com/watch?v=tfQdtPbYhV0) - Julie Moronuki, Monadic Warsaw lectures.  Her six-part course begins with a review of Type Class, then Functors (covariant & contravariant) and finally to Profunctors.  Slides are linked in the comments section of the videos.
* [24 Days of Hackage: contravariant](https://ocharles.org.uk/blog/guest-posts/2013-12-21-24-days-of-hackage-contravariant.html) - an awesome tutorial which served as the basis for my contravariant section.
* [Fun with Profunctors - speaker deck](https://speakerdeck.com/paf31/fun-with-profunctors) - Phil Freeman, LA Haskell Meetup. He starts with an introduction to covariant and contravariant functors, then works his way to Profunctors and demonstrates how they were utilized in PureScript's [Lens Library](https://github.com/purescript-contrib/purescript-lens). You'll want to watch the video of his lecture (linked below) more than once.
* [Fun with Profunctors - Youtube](https://www.youtube.com/watch?v=OJtGECfksds)


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
