# You've been using Monads
![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 15** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 15](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15)

Welcome to Tutorial 15 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we're going to examine the `pure` function applied to a few types we covered in the past.  In some respect, you can think of the function `pure` as the equivalent of JavaScript's `of` function. In JavaScript, a *pointed functor* is a functor with an `of` method.  However, you'll likely never hear someone within the PureScript community refer to a Pointed Functor because there is no type class for it.  More on this later.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-lifting-into-a-pointed-functor) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

The markdown and all code examples for this tutorial are on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).


## What it means to be a monad

Yes.  The type constructors Box, Either, Task, List, and Array utilized in previous tutorials are not only Functors, but they're also Monads.  Why? Because, by adding a few more laws to Functor, it becomes a Monad.  Recall from [Tutorial 14]( ) that any type constructor that we can `map` over is a Functor.  Furthermore, in [Tutorial 15]() we learned that the function `pure`  is used to lift a value or expression into a Functor.  In a future tutorial, we'll give this type of Functor the name, Applicative Functor.   Finally, any Applicative Functor, which you can call `bind` on is a Monad.  Each of these types adds more capability to the former while adhering to the functor laws; starting with Functor, followed by Applicative Functor, and finally Monad.

From the last two tutorials, you should understand what it means to call `map` and `pure` on a type constructor, making them Functors and Applicative Functors respectively.  Now, when we have a type constructor that we can call `bind` on, we have ourselves a monad.  So essentially, the only thing missing in our monad understanding is `bind`.  As Brian mentions in his [video](), the `bind` operation in PureScript has the same meaning as `chain`  of `flatMap` in other functional programming languages.  It also has an infix operator `>>=`, which is extremely useful in practice.

So, in addition to `map` and `pure`, monads are type constructors that you can also call `bind` on.  Its purpose is to avoid double nesting your type constructor, avoiding messes like `Just (Just a)` or `Left (Right a)`, for example.  Using the example from Brian's [video](),  imagine we have a task `httpGet` that gets a user, followed by another `httpGet` that gets this user's comments.  Here's the following pseudo code:

```haskell
getComments =
     httpGet "/user" 
     # \user → map $ httpGet $ "comments/" <> user.id
```
Left unmodified, we obtain a problematic result of `Task(Task([Comment])`, making it difficult to work with this constructor.  However, if we call `bind` on our first task, then we avoid nesting tasks, enabling us to avoid `map` and extract the comments with a single fork.  Here's what that looks like in pseudo code, using the infix operator `>>=` for bind:

```haskell
getComments :: ∀ e. TaskE e Comments
getComments =
 httpGet "/user" >>= 
    \user →  httpGet $ "comments/" <> user.id
    # fork (\e → e) (\xs → xs)
```

So, instead of `Task(Task([Comment])`, we end up with `Task([Comment])`.  More formally, the type signature for `bind` is:

```haskell
bind :: ∀ a b m.  Bind m => m a → (a → m b) → m b
```
This read, given values or expressions `a` and `b` and a monad `m` , such that `m` adheres to the laws of the type class `Bind`, the function `bind`  takes the `a` out of `m`, then applies the function `a → m b` and returns `m b`.    What does it mean to "adhere to the laws of type class bind"?  Well, there are essentially two laws that a type constructor must follow to be a monad.  We'll demonstrate them with code examples:

```haskell
-- Monad law 1 join(m.map(join)) == join(join(m))
m1 :: Box (Box (Box Int))
m1 = pure $ pure $ pure 3

result1 :: Box Int
result1 = join $ map join m1

result2 :: Box Int
result2 = join $ join m1

main = logShow $ result1 == result2
```

## Do notation

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
