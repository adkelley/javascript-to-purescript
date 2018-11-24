# Applicative Functors for multiple arguments

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 18** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the [series introduction](https://github.com/adkelley/javascript-to-purescript) where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 17](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17)

In this tutorial, I'm going to show how you can apply a function to multiple functor arguments by using the Applicative Functor.  In essence, this type class extends the `map` operation by enabling function application to more than just one functor value.  It can also lift functions of zero arguments into a type constructor.  That is, `forall a f. Applicative f => a -> f a`.  So think of Applicative as having a few more superpowers than Functor.

Applicative functors are not only related to Functors, but also to Monads (more on this below).  So I'll review the Functor and Monad type classes, which we covered in [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14/Readme) and [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme) respectively, before going into applicative functors in detail.  You'll find all the code examples in this tutorial, in my [github repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18).

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf – thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/angular-1-x-applicative-functors-for-multiple-arguments) before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it's better that you understand its implementation in the comfort of JavaScript.

## Quick Functor review
As we learned from [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14/Readme), the definition of a functor is straightforward–it is any type constructor that supports a map operation: 

```haskell
map :: ∀ a b. (a → b) → f a → f b
```
Here `f` is any 'containery' type constructor, such as a list, or 'non-containery' such as the function type constructor `( (→ ) r) = r → b`.  A  functor also obeys a few laws; with the first being the preservation of function composition while mapping.  The second law is even more straightforward; it shows that mapping over a functor with the identity function produces the same result as applying the identity function to the functor.

## Would you like to superclass your order?
In [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme) we hinted that an applicative functor has a method `pure` that lifts a value or expression into a functor type constructor (more on this later).  Moreover, any applicative functor, for which you can call the `bind` function on is a monad.  So essentially the Functor, Applicative Functor, and Monad type classes (in this order) add more methods to its predecessor while adhering to their laws.  

Consequently, we can say that Functor is a superclass of Applicative because you can give an instance of Functor to an Applicative: 
 
```haskell
 map f a = pure f   <*> a
```  
Note, we'll learn about the `apply` method, whose infix operator is `<*>` , shortly.  

In turn, Applicative is a superclass of Monad because you can give an instance of Applicative to a Monad:
```haskell
f <*> a = do
  f' <- f
  a' <- a
  pure (f' a')
```
 Let’s quickly review Monads from [Tutorial 16] .(https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme)

## Quick Monad review
To be considered a Monad, a type constructor must not only be able to accept `map` and `pure`, but it must also support the `bind` operation, whose infix operator is `(>>=)`.  This operation has the same meaning as `chain` or `flatMap` in other functional programming languages.  The main purpose of `bind` is to prevent double nesting of a type constructor when applying multiple operations on it, avoiding messes like `Just (Just a)`.  Like Functor and Applicative, Monads have laws; including the Associativity law, and the Left and Right Identity laws and m, respectively.

With Functors and Monads out of the way, we're ready to tackle applicative functors.

## Applicative Functor
In Brian's [video](https://egghead.io/lessons/angular-1-x-applicative-functors-for-multiple-arguments), he points out that Applicative is, in effect, flipping `map` around to allow us to apply a function to multiple functor arguments instead of just one.  From Brian's example, let's break out our familiar `Box` constructor to try and add two numbers together - `Box 2` and `Box 3`.  Using the PureScript REPL  (i.e., `$ purs repl`), with our Functor powers alone, we could partially apply `map` to the first argument:

```haskell
> :t (+) `map` (Box 2)
Box (Int -> Int)
```
However, as shown above, this leaves us with a function and a value wrapped in `Box` with no way to apply `Box 3` to get our final result.  You can try ```(+) `map` (Box 2) `map` (Box 3)```  in the REPL to convince yourself of this fact.  

Instead, we'll lean on a method belonging to the Applicative Functor type class, appropriately named `apply`.  This method allows us to map a function over multiple functor arguments, thereby dropping the single argument limitation of `map`:

```haskell
>: t  Box (+) `apply` Box 2 `apply` Box 3
Box Int
```
Note that, like `<$>` (i.e., the infix operator for `map`), `apply` has its own infix operator `<*>`.  So we can rewrite the above examples idiomatically as:

```haskell
> :t (+) <$> Box 2
Box (Int -> Int)
>: t  pure (+) <*> Box 2
Box (Int → Int)
> pure (+) <*> Box 2  <*> Box 3
Box 5
> (+) <$> Box 2  <*> Box 3
Box 5
```
Notice on the last input line to the REPL, I combined both `map` and `apply` to obtain the same result, as using `apply` consecutively (show in the previous lines) in the expression.  The choice is yours, whether you wish to use a combination of `map` and `apply` or `apply` by itself.  If it's the latter, then first be sure to use `pure` to lift the function into your type constructor, before applying the functorial argument.  

So it should be no surprise that when comparing the type signatures of <$> and <*>, we see a substantial similarity:

```haskell
-- | map
(<$>) ::  Functor f
          ⇒ (a → b) → f a → f b

-- | apply
(<*>) :: Applicative f
         ⇒ f (a → b) → f a → f b
```
The only difference is that `apply` expects that you have lifted the function `(a → b)` into the type constructor `f` already.  

### Applicative is a monoidal functor
Finally, It's also important to recognize that, compared to Functor,  Applicative is a [monoidal](https://medium.com/@kelleyalex/ensure-failsafe-combination-using-monoids-adc745659a3b) functor, because it can combine multiple functor arguments into a single applicative functor.

```haskell
>   [\x → x + 1, \y → y * 2] <*> [1, 2]
[1, 3, 2, 4] 
```
The above example applies an Array of functions that make up the morphism (i.e., values to the left of (<*>)) to the Array of arguments independently; returning the results in a single Array.  This quality is the key reason why Applicative is a very good type constructor for implementing concurrent (see [below](#concurrency) ) operations.

 ### using the `lift` helper methods
Stringing multiple functor arguments together with `apply` can get a little tedious:

```haskell
Box (+) <*> Box 2 <*> Box 3 <*> Box 4 ...
```
Instead, the [Control.Apply] (https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Apply) package provides us with a few helper methods, `lift2`, `lift3`, `lift4` , ... to lighten our load.  The number in the name of these methods represents the number of functorial arguments.  For example, using the REPL, we can rewrite our "add two numbers contained in Box" using `lift2` like this:

```haskell
> import Control.Apply
> :t lift2
lift2 :: forall a b c f. Apply f => (a -> b -> c) -> f a -> f b -> f c
> lift2 (+) (Box 2) (Box 3)
Box 5
```
We see that `lift2` takes care of lifting our function `(+)` into a `Box` and applying it to `Box 2` and `Box 3` to get our result `Box 5`.   Ok, we're well on our way to understanding the Applicative Functor.  To close this tutorial, we'll cover the `pure` method and the functor laws for Applicative. 

### Use `pure` to lift functions of zero arguments
Earlier we saw that the `map` method gives us the ability to lift a function of one argument to work on a value wrapped in a type constructor.  This capability implies that the type constructor is a Functor.  We later saw that `apply` or it's helper functions, `lift2, lift3, ..., give us the ability to lift functions of two or more arguments to work on values wrapped with a type constructor.  It implies that the type constructor is an Applicative Functor. 

What if we just want to lift a function of zero arguments into a type constructor?  In this case, we call on the method `pure`, which is part of the [ Control.Applicative](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative) module.  As a result, we see that that Applicative functors support a lifting operation for any number of arguments.  From the documentation, the `Applicative` type class extends the `Apply` type class with a `pure` function, which can be used to create values of type `f a` from values of type ``.

By adding `pure`  to our toolbox, we can modify our REPL example to the following:

```haskell
> import Control.Apply
> import Control.Applicative
> :t pure
forall a f. Applicative f => a -> f a
> import Data.Box
> :paste
...addOne :: Box (Int → Int)
...addOne = pure (\x → x + 1)
> (^D)
> addOne <*> (Box 2)
3
```
## Applicative Functor Laws
As George Wilson likes to say in his talks, [ "Functors have laws!"](https://youtu.be/JZPXzJ5tp9w?t=146), so it's should be no surprise that the Applicative Functor has laws too.  As you may recall, `Applicative` adds additional capability to `Functor`.  So, naturally, it inherits the laws from Functor (i.e., Identity and Composition) and some additional ones. 
hom==
```
1. Identity
pure identity <*> v ≡ v

2. Homomorphism
(pure f) <*> (pure x) ≡ pure (f x)   

3. Interchange
 u <*> (pure y) ≡ (pure (_ $ y)) <*> u

4.  Associative Composition
pure (<<<) <*> f <*> g <*> h ≡ f <*> (g <*> h)
```  

1. The identity law says that mapping identity function over a functorial value produces the same result as applying the identity function directly to the functor.  
2.  The Homomorphism law states that applying a `pure` function `f` to a `pure` value `x` is the same as applying `pure` directly to the function evaluation `f x`.
3.  The Interchange law says that applying a function `u` to a "pure" value, `pure y`, is the same as applying `pure (_ $ y)` to the function `u`.  Note that `(_ $ y)` is a higher order function, meaning it supplies `y` to another function.
4.  Associative composition says that applying a composed morphism gives the same result as applying `f` to the result of `g` to `h`.

Keep these in your back pocket to help you in forming your expressions that take advantage of Applicative Functors.

## What is an Applicative good for? {#concurrency}
Now to the punchline – what good are Applicative Functors?  Well, they do help to avoid a lot of boilerplate when working with type constructors that are functors (e.g., `Maybe`).  For example, the `Maybe` applicative functor represents the side-effect of possibly-missing values.  Phil Freeman, in his book, [PureScript by Example](https://leanpub.com/purescript/read#leanpub-auto-generalizing-function-application), shows how we can use `Maybe` (an applicative functor) to validate multiple fields within an address book, that may have missing values.

Applicative functors are also a great type constructor for implementing concurrency.  Imagine we want to fetch two pieces of data from two separate APIs.  Well, Applicative can take advantage of concurrency by fetching both arguments simultaneously, whereas a Monad cannot due to the serial nature of `(>>=)`.

## Useful References
1. Applicative Validation [PureScript by Example] (https://leanpub.com/purescript/read#leanpub-auto-applicative-validation)
2.  Wikibook - Haskell [Applicative functors](https://en.wikibooks.org/wiki/Haskell/Applicative_functors)
3.  Chapter 17.  Applicative [Haskell Programming From First Principles](http://haskellbook.com/) 


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19)

