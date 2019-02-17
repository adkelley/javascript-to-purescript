# Apply multiple functors as arguments to a function (Applicatives)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 19** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-month. So come back often, there’s a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 18](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18) | [>> Tutorial 20](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20)

In the last tutorial, I introduced the Applicative Functor for applying a function to multiple functor arguments.  Now, I'm going to show a practical example of this functor - getting a web page's screen height from the DOM.  However, first, let's take a quick refresher on Applicative Functors then dive right into the example. 

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf — thank you, Brian! A fundamental assumption of each tutorial is that you’ve watched his [video](https://egghead.io/lessons/javascript-applying-applicatives-exhibit-a) before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.


## Quick Applicative Functor review
From the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18), we learned that the Applicative Functor type class extends the [map](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Data.Functor) method by enabling function application to more than one functor value. Also, it can lift functions of zero arguments or values into a functorial type constructor. To accomplish the former we use the `apply` method, and the latter is achieved using `pure`.  For example, using the PureScript REPL, we can play with our old friend the `Box` type constructor to see how `apply` and `pure` work:

```haskell
> import Control.Apply
> import Control.Applicative
> import Data.Box
> import Prelude
> pure (+) `apply` (pure 2) `apply` (pure 3) :: Box Int
Box 5
```
The `pure` method, from the [Control.Applicative](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Applicative) module, lifted our addition function `(+)` and the values `2`, and `3` into our `Box` constructor.  The `apply` method, from PureScript's [Control.Apply](https://pursuit.purescript.org/packages/purescript-prelude/4.1.0/docs/Control.Apply) module, maps `Box (+)` over the arguments `Box 2` and `Box 3` to calcuate and return `Box 5`.  Note, we could have assigned these functor arguments to `Box` directly (e.g., `Box (+)`) without using `pure`.  However, in production code, I prefer to use it in case I decide to change the name of the type constructor later on.  This way it's a simple name change to one or more arguments in a function's type declaration, avoiding error-prone edits to arguments within the body of the function.  We also learned that there's an infix operator for `apply`, namely `<*>`:

```haskell
> (+) <$> (pure 2) <*> (pure 3) :: Box Int
Box 5
```
Recall that `map`, whose infix operator is `<$>`, enables the substitution of `pure`, and one `apply` from an applicative expression.  Thus, from the above, `map` 
takes care of lifting our function into `Box`, such that `(+)` is partially applied to each argument within `Box` to obtain the result of the addition.


Also, there are helper methods `lift2`, `lift3`, `lift4`, etc., that help to shorten our code even further.  The number in the name of these methods represents the number of functorial arguments to the function. For example:

```haskell
> lift2 (+) (pure 2) (pure 3) :: Box Int
Box 5
```
## Calculating webpage screen height
Now that our refresher is complete, we're ready to calculate the screen height from the DOM.   I translated Brian's JavaScript code directly into PureScript, so be sure to review his [code](https://egghead.io/lessons/javascript-applying-applicatives-exhibit-a) first, so that you understand the context of this example.

I chose to model the `Selector` DOM node element using a record type; creating an instance of `show` to help log the screen height to the console:

```haskell
newtype Selector = Selector
  { selector :: String
  , height :: Int
  }

instance showSelector :: Show Selector where
  show (Selector s) = show s.height
```
If you're not familiar with the `newtype` keyword, this algebraic data type (ADT) gives us the ability to name an existing type constructor. In our case is a record describing the name of the selector and its height.  There is no performance penalty from using `newtype`s because its values have the same runtime representation as the underlying type.  Be sure to check out [5.12 Algebraic Data Types](https://leanpub.com/purescript/read#leanpub-auto-algebraic-data-types) from 'PureScript by Example' for further details.

Next, we'll stub in a function that takes a fake DOM node element name as an argument, and uses this name to construct a `Selector`.  We'll wrap the `Selector` in an Either constructor, introduced in [Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) to factor in the possibility of an error when retrieving this DOM node:

```haskell
getSelector :: String -> Either Error Selector
getSelector selector =
  pure $ Selector { selector, height: 10 }
```
Note once again our use of the `pure` method, which lifts functions or values into a functorial type constructor; be it a Functor, Applicative, or Monad type class. We used it to lift `Selector` into the `Either` type class constructor.  Remember that this function is just a stub, and therefore there are no side-effects.  So `getSelector`  always returns `Right $ Selector { selector, height: 10 }`.

Here is the function that calculates our screen size height:

```haskell
getScreenSize :: Int -> Selector -> Selector -> Selector
getScreenSize screen (Selector header) (Selector footer) =
  Selector { selector: "screen"
           , height:   screen - (header.height + footer.height)
           }
```

This example is an excellent representation of PureScript's pattern matching capabilities.  Notice that we reference both the `header` and `footer` from inside the `Selector` type constructor, enabling the ability to calculate the height of our screen without any contortions. Nice!

Next, I'll show two approaches for retrieving the header and footer selectors, before calling `getScreenSize`.  The first approach is sequential, retrieving the `header` and `footer` by treating our `Selector` constructor as a monad. Hopefully, monads are familiar already.  If not, then read [You've been using Monads!](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16) first, before proceeding.

### Treating `Selector` as a Monad

```haskell
result1A :: Either Error Selector
result1A =
   (getSelector "header") >>=
      \header -> (getSelector "footer") >>=
         \footer -> pure $ getScreenSize 800 header footer
```

As a first cut, I might use monad chaining to retrieve the `header` size argument, followed by the `footer`.  The above shows how to chain these two arguments using the `bind` operator `>>=`.  However, from [Tutorial 16](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16), we know that chaining becomes difficult to read rapidly. Thus, for threading two or more arguments onto the next computation, I think that a `do block` is better for readability.

```haskell
result1B :: Either Error Selector
result1B = do
   header <- getSelector "header"
   footer <- getSelector "footer"
   pure $ getScreenSize 800 header footer
```

### Treating `Selector` as an Applicative

Now onto the crux of this tutorial.  Given that retrieval of both the header and footer nodes are independent operations, let's treat the `Selector` constructor as an Applicative Functor and use `apply` to retrieve these arguments in parallel.

```haskell
result2 :: Either Error Selector
result2 =
  pure (getScreenSize 800) <*> (getSelector "header") <*> (getSelector "footer")

-- | Shorten result2 by using lift2
result3 :: Either Error Selector
result3 = 
  lift2 (getScreenSize 800) (getSelector "header") (getSelector "footer")
```

The above example shows two approaches; `result2` uses the infix operator for `apply`, namely `<*>`.  The `result3` function is slightly shorter because it uses the `lift2` helper method; declaring the two arguments required by the function.

There is actually one more approach, introduced in PureScript compiler version 0.12, which takes advantage of Applicative do-notation.  The syntax is similar to do-notation, which we saw in `result1B` from the code example above. However, instead of treating `Selector` as a monad, we use the `ado` keyword to tell the compiler to treat it as an Applicative.  We also replace `pure` with the `in` keyword.  

A key motivation for `ado` is that Applicative syntax can be difficult to read and write, particularly when there are more than two functorial arguments.  For example (co-opted from the Glasgow Haskell Compiler [documentation](https://ghc.haskell.org/trac/ghc/wiki/ApplicativeDo)):

```haskell
(\x y z → x*y + y*z + z*x) <$> expr1 <*> expr2 <*> expr3

vs.

ado 
  x <- expr1
  y <- expr2
  z <- expr3
  in (x*y + y*z + z*x)
```

shows how we can make use of all the applicative benefits while still being able to use do-notation sugar.  Similarly, rewriting our `getScreensize` example to take advantage of Applicative do-notation is a trivial exercise:

```haskell
result4 :: Either Error Selector
result4 = ado
  header <- getSelector "header"
  footer <- getSelector "footer
  in getScreenSize 800 header footer
```

As a final point, I should mention that this all works thanks to currying, which I covered in [Tutorial 17](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03).  That is, `getScreenSize` becomes a series of nested functions.  This means that the expression `result = getScreenSize 800  (getSelector "header") (getSelector "footer")` is transformed to `f1 = getScreenSize 800`; `f2 = f1 (getSelector "header")`; and `result = f2 (getSelector "footer")`.


## Summary
In this tutorial, we saw an example of how to employ Applicatives in our code. Whenever you need to apply a function to multiple functorial arguments, and their calculation or retrieval is independent of one another, then it's best to treat the type constructor as an Applicative, rather than a Monad (see [Treating `Selector` as an Applicative](#treating-selector-as-an-applicative)).  This way, we can calculate or retrieve the function's arguments in parallel.  On the hand, if the value of one or more function arguments is dependent on the value of another argument, then treat the type constructor as a Monad.  This approach calculates or retrieves the arguments sequentially; threading the values through the monad until you have your final result (see [Treating `Selector` as a Monad](#treating-selector-as-a-monad)).

I hope, with this practical example, you found the concept of applying multiple functors as arguments to a function (i.e., Applicatives) to be easy to understand. In the next tutorial, I'll show another practical example using list comprehensions. That is, using an Applicative Functor to create a list based on existing lists.  If you're enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media. Thank you and until next time!
