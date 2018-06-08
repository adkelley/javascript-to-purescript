# You've been using Functors
![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 14** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 13](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)


Welcome to Tutorial 14 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we are going to explore one of the most common and useful abstractions in the functional programming world - Functors!  Yes, it's a scary, mathematical term indeed.  However, as the title of this tutorial states, we've been using functors throughout this series - only I never called it out.  I hope that, after you finish this tutorial, you find that functors aren't scary at all. Instead, they're incredibly useful and its definition and laws serve as a basis for future abstractions in this series, including Applicative Functors and Monads.  By recognizing them and knowing their laws, I guarantee your understanding will serve you well throughout your functional programming adventures.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-delaying-evaluation-with-lazybox) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Definition of a Functor
In functional programming, the definition of a functor is straightforward - it is any type with a map method.  Let me repeat - a functor is any type with a map method.  A functor also obeys a few laws which we'll cover shortly. So, you might be asking, "what was all my anxiety about?"  Well, unless you've studied category theory, then you've likely never heard of a 'functor' before.  In category theory (i.e., mathematics), a functor is used to describe a mapping between categories. Similarly, in functional programming, we use it to describe the ability to perform a map operation over some structure. For instance, take a moment and go back to review [Tutorial 10]().  In that tutorial I introduced the type signature of the `map` function:

```haskell
  map :: ∀ a b. (a → b) → f a → f b
```

As you might expect, it explicitly states that `f` is a functor if and only if it has a `map` function.  Thus `f` is the structure that we map over.  Many structures qualify as functors; the canonical example being lists or arrays.  Whenever we map a function from `(a → b) ` over a structure of `a`s to get a structure of `b`s then that structure is a functor.  Referring back to [Tutorial 10](), let's have another look at our `Additive Int` example.  I've aligned the type signature of `map'` with `map` to make it easily apparent.  Here we are mapping the `Sum` type constructor over a `List` of `Int`s and we get back a `List` of `Int`s wrapped in `Sum`s (i.e., `List Sum`). 
 
```haskell
type Sum = Additive Int

map :: (a   -> b  ) -> f    a   -> f    b
map':: (Int -> Sum) -> List Int -> List Sum
map' = map

map' Sum (1 : 2 : 3 : Nil) -- (Sum 1 : Sum 2 : Sum 3 : Nil)
```

## Functor Laws
What would a functor be without a couple laws for us to know and leverage in practice. The first law of functors is one that preserves function composition while mapping.  It's easier to show the code first then explain, so taking the first code example from this tutorial:

```haskell
-- | First law of Functors
-- | fx.map(f).map(g) == fx.map(x => g(f(x)))

-- | Box("RELS")
res1 :: Box String
res1 =
  Box "squirrels"
  # map (\str -> substrImpl 5 str)
  # map toUpperCase

-- | Box("RELS")
res2 :: Box String
res2 =
  Box "Squirrels"
  # map (\str -> toUpperCase $ substrImpl 5 str)
```

Here the functions `res1` and `res2` produce the same result, but `res2` is more efficient.  They're equivalent because the functor laws guarantee that mapping over a functor `f` with the composition of two functions `fn1` and `fn2` (i.e., `fn2 <<< fn1`), as shown in `res2`, is no different than mapping over the functor twice - once with `fn1` followed by `fn2`, as shown in `res1`.  Moreover `res2` like functions will always more efficient than `res1` because we only map over our structure once. Imagine that, instead of `Box`, we had a long list of strings. Then mapping over the list once is much more efficient than mapping over it twice.  So I think it demonstrates that knowing and implementing these laws in practice can help you to be a better functional programmer.

The second law is even simpler.  It shows that mapping over a functor `f` with the identity function produces the same result as applying the identity function to the functor. As a reminder, the identity function takes an `x` and returns that `x`. Here again, perhaps it's easier to show than to explain:

```haskell
-- | Second law of Functors
-- | fx.map(id) == id(fx)

-- | Box("crayons")
res3 :: Box String
res3 =
  Box "crayons"
  # map identity

-- | Box("crayons")
res4 :: Box String
res4 =
  identity (Box "crayons")
```

In summary, for a structure to be a functor, it must have a mapping operation, and it must preserve identity morphisms and the composition of morphisms.  Here a morphism refers to a structure-preserving map from one structure to another.  That's all there is to it.  However, before we go, let's explore a few more abstractions that belong to the family of functors.  They are used much less frequently than functors but they're worth knowing and having in your tool chest.

## Bifunctors
Similar to a Functor, a Bifunctor is any structure `f` with a binary mapping operation (`bimap`) over two type arguments. The canonical example is a list or array of `Tuple`.  For greater clarity, let's look a the type signature for `bimap`:

```haskell
bimap :: ∀ a b c d. (a → b) → (c → d) → f a c → f b d
```

Like Functor, a Bifunctor obeys the Functor laws of composition and identity. For the sake of brevity, I won't list the code examples proving these laws, so be sure to have a look at the code in my [repository](). One interesting question is whether you can use `map` instead of `bimap` to map over a structure that has two type arguments.  The answer is a resounding YES!
```haskell
-- | What happens when we apply a functor
-- | to a Tuple?
res9 :: Box (Tuple String String)
  Box $ Tuple "crayons" "markers"
  # map  (\str -> toUpperCase $ substrImpl 5 str)
```
Here, we ignore the left argument and apply the function `(a → b)` to the right argument.  Instead, for better readability, I suggest you should use the function `rmap` from `Data.Bifunctor`.  If you need to map the left argument, then `Data.Bifunctor.lmap` is your answer.

## Profunctors

And for the grand finale, let's go over the topic of `Profunctors`.  I can't tell you how many time I have watched Phil Freeman's popular [video](), scratching my head in frustration.  


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
