# Lift into a Pointed Functor with pure
![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 15** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 13](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)

Welcome to Tutorial 15 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we're going to examine the `pure` function on a few types and discover it's Pointed Interface.  In one respect, you can think of the function `pure` as the equivalent of JavaScript's `of` function. In JavaScript, a *pointed functor* is a functor with an `of` method.  Thus, a pointed functor in PureScript is any functor (see [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14) with a `pure` function.  We more commonly refer to it as an Applicative Functor, but that's a topic we'll cover in a future tutorial.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-lifting-into-a-pointed-functor) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

The markdown and all code examples for this tutorial are on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Lifting into a Pointed Functor
In past tutorials, I showed you the method for taking a concrete value or expression `a` and applying a type constructor `f` to get `f a`.   We did this using type constructors such as `Box`, `Either`, `Maybe`, and `Task`.  What I didn't mention is the name of this process, which is called `lifting`. The intuition is that we are embedding the `a` in some broader context.   

For example, when we embed a value in the `Either` type constructor, I like to think that we're putting it into the context of  "values with two possibilities".  The possibilities are that this value is either a `Left a` or a `Right b`.  Also, by convention, `Right b` is used to represent a value that is correct, while `Left a` is considered an incorrect value.  This convention implies that we have a contract with the compiler that says "whenever you see a `Right b` then map or chain my functions on the `b` until I have a result OR until you encounter a `Left a`".  "If you encounter a `Left a` then stop any further mapping or chaining and return `Left a`".  

In JavaScript, we lift a value into a pointed functor using the `of` function.  For example, we know from the previous tutorial that Arrays are functors because they have a map operation.  Therefore, in JavaScript, `of = x ⇒ [x] ` lifts `x` into the pointed functor `Array`.  The equivalent to `of`  in PureScript is the function `pure`.  So lifting `x` into the pointed functor `Array` is `pure x = x → Array x`.

## Hello Either
 Let's look at the Either type constructor:

```haskell
-- | either.of(x) == pure x-- | either.of(x) == pure x
-- | returns Right "hello"
eitherHello :: Either String String
eitherHello = pure "hello"

main = do
  logShow $ map (_ <> "!") eitherHello
```
We use the function `pure` to lift our value `hello` into `Right `hello`.   Then, in `main`, we map over the functor by lifting the expression `(_ <> "!")` into the `Either` context.  Since `eitherHello` returns `Right "hello"`, we can successfully `map`  the expression (_ <> "!")  to "hello", logging `Right "hello!"` to the console.  

## Hello Task
The constructor `TaskE` is a little more interesting:

```haskell
-- | returns (TaskE a "hello") where a is a String
taskHello :: TaskE String String
taskHello = taskOf "hello"

-- | returns (TaskE "noHello" b), where b is a String
-- | taskRejected == throwError
taskNoHello :: TaskE String String
taskNoHello = taskRejected "noHello"

showTask :: TaskE String String → Task Unit
showTask =
  fork (\e → log $ "err " <> e) (\y → log $ "success " <> y)

main = do
  void $ launchAff $ showTask taskHello

```
Underneath the covers, `TaskE` is just one step removed from the `Either` type constructor.  Its type signature is: `type TaskE x a = ExceptT x Aff a`.  Here `ExceptT` is a monad transformer that allows us to combine multiple monads to form a new monad.  Yes, I know we haven't covered monads but bear with me until we finally cover them in detail in the next tutorial.  

When we call `taskHello` we use `taskOf` to construct a `(TaskE x "hello)` functor.  Noted that the function `taskOf` is merely a type signature for `pure` and I could've easily substituted it.  Next is the call to `showTask` which performs most of the magic.  It takes our `TaskE x "hello"` and immediately calls `fork`.  The type signature for `fork` is:
```haskell
fork
  :: ∀ c b a
   .   (a → Task c) 
   → (b → Task c)
   → TaskE a b
   → Task c
```
Its purpose is to tell the compiler what to do in case of two possibilities; either a value that is correct or incorrect.  You may be asking - "how does the compiler know what is a success and what is a failure?"  Well, that's where our friend `Either` comes into play, but hang on to that thought for a moment.  We supply `fork` with two functions for handling an error or success respectively.  We also pass it our `TaskE x "hello`  constructor.  

Now you should begin to see a connection to the `Either` constructor.  If we had a way of transforming `TaskE x "hello` to a `Right "hello` then it's easy to tell the compiler to perform our success function `\y → log $ success: " <> y` .  Conversely, when we transform `TaskE "hello" a` into a `Left "hello` then the compiler will know to perform our error function `\e → log $ "error: " <> e`.   

Where there's a will, there's way, and it comes in the form of the function `runExceptT`.  This function takes our `TaskE x "hello" and transforms it into a `Right "hello"`.  How?  Well by lifting our value "hello" into the context `TaskE x "hello` we are effectively telling the compiler that our value is correct, because "hello" appears on the right.  So the compiler returns a `Right "hello"`.  The process of returning `Left "hello"` is similar and is *left* (no pun intended) to the reader.  Hint: have a look at the type signature for runExceptT using [Pursuit]( https://pursuit.purescript.org/search?q=runExceptT).

## Summary


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
