# Applicative Functors for multiple arguments

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 18** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the [series introduction](https://github.com/adkelley/javascript-to-purescript) where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 17](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17) | [>> Tutorial 19](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19) [>>> Tutorial 20](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20)

In this tutorial, I'm going to show how you can apply a function to multiple functor arguments by using the Applicative Functor.  In essence, this type class extends the `map` operation from the Functor class to enable function application to more than just one functor value.  It can also lift functions of zero arguments and values into a functorial type constructor.  So you can think of Applicative as having a couple more superpowers over Functor.

Applicative functors are not only related to Functors, but also to Monads (more on this below).  So, before going into applicative functors in detail, I'll review the Functor and Monad type classes, which we covered in [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14/Readme) and [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme), respectively.  You'll find all the code examples in this tutorial, in my [github repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18).

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf – thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/angular-1-x-applicative-functors-for-multiple-arguments) before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it's better that you understand its implementation in the comfort of JavaScript.

## Quick Functor review
As we learned from [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14/Readme), the definition of a functor is pretty straightforward–it is any type constructor that supports a map operation: 

```haskell
map :: ∀ a b. (a → b) → f a → f b
```
Here, `f` is any type constructor, such as a list, or even a 'non-containery' one, such as the function type constructor `( (→ ) r) = r → b`.  A  functor also obeys a few laws.  The first law is the preservation of function composition while mapping.  The second law is even more straightforward; it shows that mapping over a functor with the identity function produces the same result as applying the identity function to the functor.

## Would you like to superclass your order?
In my [Monad tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme), I mentioned that there is the `pure` method which lifts a value or expression into a functor type constructor.  At last, we can give this type of functor a name – Applicative Functor.  Moreover, any applicative functor, for which you can call the `bind` method on, is a Monad.  So essentially, the Functor, Applicative Functor, and Monad type classes (in this order) add more methods to its predecessor while adhering to their laws.

Using the above logic, we say that Functor is a superclass of Applicative because you can give an instance of Functor to any Applicative Functor:
 
```haskell
 map f a = pure f <*> a
```
As for `<*>` in the above example, it is the infix operator for the `apply` method, which I'll cover shortly.

In turn, Applicative is a superclass of Monad because you can give an instance of Applicative to any Monad:
```haskell
f <*> a = do
  f' <- f
  a' <- a
  pure (f' a')
```
 In the above example, recall from [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/Readme) that `<-` is the assignment operator in a `do` block, which unwraps the value or function from its type constructor and assigns it to a variable name.

## Quick Monad review
To be considered a Monad, a type constructor must not only be able to accept the `map` and `pure` methods, but it must also support the `bind` method, whose infix operator is `(>>=)`.  This operation has the same meaning as `chain` or `flatMap` in other functional programming languages.  The main purpose of `bind` is to prevent double nesting of a type constructor when applying multiple sequential operations on it; avoiding messes like `Just (Just a)`.  Like Functor and Applicative, Monads have laws - the Associativity law, and the Left and Right Identity laws and m, respectively.
Now, with our Functor and Monad review out of the way, we're ready to tackle applicative functors.

## Applicative Functor
In Brian's [video](https://egghead.io/lessons/angular-1-x-applicative-functors-for-multiple-arguments), he points out that Applicative is, in effect, flipping `map` around to allow us to apply a function to multiple functor arguments, instead of just one.  In Javascript, Brian named this apply method `ap` and added it to our Box object:

```javascript
const Box = x =>
({
  ap: b2 => b2.map(x),
  map: f => Box(f(x))
  ....
)}
```
Here, `x` is our function and `b2` is the Box holding a value.  Translating Brian's example from his video, let's break out our familiar `Box` constructor to try and add two numbers together (e.g., `Box 2` and `Box 3`) in PureScript.  Using the PureScript REPL  (i.e., `$ purs repl`), with just our Functor powers alone, `map` limits us to a partial application of `(+)` to the first argument:

```haskell
> :t (+) `map` (Box 2)
Box (Int -> Int)
```
Using `map` results in a function and a value wrapped in `Box` with no way to apply `Box 3` to get our final result.  You can try ```(+) `map` (Box 2) `map` (Box 3)```  in the REPL to convince yourself of this fact (spoiler alert – it returns a compiler error).

Instead, we'll lean on a method belonging to the Apply type class, appropriately named `apply`.  This method allows us to map a function over multiple functor arguments, thereby dropping the single argument limitation of `map`:

```haskell
>: t  Box (+) `apply` Box 2 `apply` Box 3
Box Int
```
Note that, like `<$>` (i.e., the infix operator for `map`), `apply` has its own infix operator `<*>`.  So we can rewrite the above examples idiomatically in the REPL as:

```haskell
> :t (+) <$> Box 2  -- line 1
Box (Int -> Int)
>: t  pure (+) <*> Box 2  -- line 2
Box (Int → Int)
> pure (+) <*> Box 2  <*> Box 3  -- line 3
Box 5
> (+) <$> Box 2  <*> Box 3  -- line 4
Box 5
```
Notice that on line 4, I combined both `map` and `apply` to obtain the same result, as using `apply` consecutively in the expression (shown in line 3).  This is, perhaps the most idiomatic approach, but the choice is yours. Whether you wish to use a combination of map and apply or use apply by itself.  If it's the latter then first be sure to use `pure` to lift the function into your type constructor before applying the functorial argument.

Now, it should be no surprise that when comparing the type signatures of <$> and <*>, they're almost identical:

```haskell
-- | map
(<$>) ::  Functor f
          ⇒ (a → b) → f a → f b

-- | apply
(<*>) :: Applicative f
         ⇒ f (a → b) → f a → f b
```
The only difference is that `apply` expects that you have lifted the function `(a → b)` into the type constructor `f` (did anyone mention `pure`?).

 ### Using the `lift` helper methods
Stringing multiple functor arguments together with `apply` can become tedious quickly:

```haskell
pure (+) <*> Box 2 <*> Box 3 <*> Box 4 ...
```
Instead, the [Control.Apply](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Apply) package provides us with a few helper methods, `lift2`, `lift3`, `lift4`, etc. that help to shorten our code.  The number in the name of these methods represents the number of functorial arguments.  For example, using the REPL, we can rewrite our "add two numbers contained in Box" using `lift2` like this:

```haskell
> import Control.Apply
> :t lift2
lift2 :: forall a b c f. Apply f => (a -> b -> c) -> f a -> f b -> f c
> lift2 (+) (Box 2) (Box 3)
Box 5
```
We see that `lift2` takes care of lifting our function `(+)` into a `Box` and applying it to `Box 2` and `Box 3` to get our result `Box 5`.   Ok, we're well on our way to understanding the Applicative Functor.  To close this tutorial, we'll officially cover the `pure` method along with the functor laws for Applicative.

### Use the `pure` method to do your lifting
For the sake of completeness, let's formally cover the `pure` method.  Earlier we saw that `map` gives us the ability to lift a function of one argument to work on a value wrapped in a Functor type constructor.  We later saw that the `apply` method gives us the ability to apply functions of two or more arguments wrapped in an applicative type constructor.

From the examples above, notice we use the `pure` method, which is part of the [ Control.Applicative](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative) module, to wrap functions or even values in an applicative type constructor.  From the [documentation](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative#t:Applicative), the `Applicative` type class extends the `Apply` type class with a `pure` function, which can be used to create values of type `f a` from values of type `a`.  That is, `pure :: forall a f. Applicative f => a -> f a`.  Together, these two classes give us the methods we need for a type constructor to become an Applicative Functor.

## Applicative Functor Laws
As George Wilson likes to joke in his [Functor talks](https://youtu.be/JZPXzJ5tp9w?t=146), "Functors have laws!".  So it should be no surprise that the Applicative Functor has laws too.  As you may recall, `Applicative` adds additional capability to `Functor`.  So, naturally, it inherits the laws from Functor (i.e., Identity and Composition) and some additional ones. 

```
1. Identity
pure identity <*> v ≡ v

2. Homomorphism
(pure f) <*> (pure x) ≡ pure (f x)

3. Interchange
 (pure u)  <*> (pure y) ≡ (pure (_ $ y)) <*> u

4.  Associative Composition
pure (<<<) <*> f <*> g <*> h ≡ f <*> (g <*> h)
```

1. The Identity law shows that applying the identity function to an applicative value `v` does nothing; it's the same as `v`.  
2.  The Homomorphism law shows that applying a `pure` function `f` to a `pure` value `x` is the same as applying `pure` directly to the function evaluation `f x`.
3.  The Interchange law says that applying a "pure" function `u` to a pure value, `pure y`, is the same as applying `pure (_ $ y)` to the pure function `u`.  Note that `(_ $ y)` is a higher order function, meaning it supplies `y` to another function.
4.  Associative composition says that applying a composed morphism (i.e., the expression to the left of `<*>`) gives the same result as applying `f` to the result of `g` applied to `h`.

Keep these in your back pocket to help you in forming your expressions that take advantage of Applicative Functors.

## What good is an Applicative Functor?
In the next two tutorials, we're going to cover some useful applications for Applicatives.  The punchline is that they help to avoid a lot of boilerplate and complexity when you're working with functors.  For example, the `Maybe` applicative functor represents the side-effect of possibly-missing values.  Phil Freeman, in his book, [PureScript by Example](https://leanpub.com/purescript/read#leanpub-auto-generalizing-function-application), shows how you can use `apply` together with the `Maybe` type constructor to validate multiple fields within an address book, that may have missing values:

```haskell
> import Data.Maybe
> lift3 address (Just "123 Fake St.) Nothing (Just "CA")
Nothing
```

Applicative functors are also a great type constructor for implementing concurrency.  Imagine we want to fetch two pieces of data from two separate APIs.  With an Applicative Functor, we can take advantage of concurrency by fetching both arguments simultaneously, whereas a Monad cannot run concurrently due to the serial nature of the bind operation `(>>=)`.

## Updating Data.Box to support Applicative
If you review the [source code](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18), you'll find that I added two new class instances to our familiar `Data.Box` type constructor.  From the Apply and Applicative classes, I implemented the `apply` and `pure` methods respectively, to add Applicative Functor support to `Box`.

```haskell
instance applyBox :: Apply Box where
  apply (Box f) (Box x) = Box (f x)

instance applicativeBox :: Applicative Box where
  pure = Box
```
Note that the equivalent to `pure` in Brian's javascript file (i.e., box.js) is `of`, declared in the module's exports:
```javascript
const Box = x =>
({
  ap: box2 => box2.map(x),  // x is a function here
  map: f => Box(f(x)),
 ...
})
module.exports = { Box, of: Box }
```
## Summary
In this tutorial, we learned what it fully means to be an Applicative Functor.  We hinted at it in the Functor and Monad tutorials, because we used the method `pure` from the Applicative class to lift a value into a Functor or Monad type constructor.  Now with the introduction of `apply`, which is used to apply functions to two or more functorial values, we finally have all the pieces in place.  By using the `pure` method, we can also lift functions of zero arguments or values into a functorial type constructor.

In summary, for a type constructor to be an Applicative Functor, it must have implementations of the `pure` and `apply` methods.  The Applicative Functor has laws which inherit the laws from Functor (i.e., Identity and Composition); adding Homomorphism and Interchange to the lot.

That's all for now.  In my next tutorial, we'll start using our newly found Applicative powers to remove some messy boilerplate and complexity that `map` alone cannot solve.  If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media. Thank you and till next time!

## References
1. Applicative Validation [PureScript by Example] (https://leanpub.com/purescript/read#leanpub-auto-applicative-validation) – Phil Freeman
2. Wikibook - Haskell [Applicative functors](https://en.wikibooks.org/wiki/Haskell/Applicative_functors)
3. Chapter 17.
