# You've been using Monads
![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 16** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*
>
> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 15](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15) | [Tutorial 17 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17) [>> Tutorial 24](https://github.com/adkelley/javascript-to-purescript/tree/master/tut24)

Welcome to Tutorial 16 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

At last, we've come to the topic of monads.  Like functors, we've been using them throughout this series.  But there hasn't been an appropriate time until now to discuss them in great detail.  For example, the type constructors Box, Either, Task, List, and Array, from previous tutorials, are not only Functors and Applicative functors, but they're also Monads. Just by adding a few more laws to the Functor type class, a type constructor becomes a Monad. We'll prove, by way of a few code examples, that our canonical type constructor, `Box`, adheres to these monad laws.  Together with these laws, a monad in PureScript comes with a new operator `bind`, which we'll introduce to help avoid double nesting of the same type constructor.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-you-ve-been-using-monads) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

The markdown and all code examples for this tutorial are on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).


## Functor -> Applicative Functor -> Monad

Recall from [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), that any type constructor that we can `map` over is a Functor.  Furthermore, in [Tutorial 15](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15) we learned that the function `pure`  is used to lift a value or expression into a Functor.  You can think of it as embellishing the type. In a future tutorial, we'll give this type of Functor the name, Applicative Functor.   Finally, any Applicative Functor, which you can call `bind` on is a Monad.  Each of these types adds more capability to the former while adhering to their laws; starting with Functor, followed by Applicative Functor, and finally Monad.

From the last couple tutorials, you should understand what it means to call `map` and `pure` on a type constructor, making it both
a Functor and Applicative Functor respectively.  Now, in addition to `map` and `pure`, when we have a type constructor that we can call `bind` on, then it is also a Monad.  As Brian mentions in his [video](https://egghead.io/lessons/javascript-you-ve-been-using-monads), the `bind` operation in PureScript has the same meaning as `chain` or `flatMap` in other functional programming languages.  It also has an infix operator `>>=`, which you are going to find to be very useful in practice.

The main purpose of `bind` is to prevent double nesting of a type constructor, avoiding messes like `Just (Just a)`, to name one example.  Using the code example from Brian's [video](https://egghead.io/lessons/javascript-you-ve-been-using-monads),  imagine we have a task `httpGet` that gets a user, followed by another `httpGet`, that retrieves this user's comments from our data store.  Here is the pseudo code:

```haskell
getComments =
  httpGet "/user" 
  # map \user → httpGet $ "comments/" <> user.id
```

Left unmodified, we end up with the problematic result of `Task(Task([Comment])`, making it difficult to work with this type constructor.  However, if we call `bind` on our first task, then we avoid nesting the two task type constructors and the need for `map`.  Here's what it looks like in pseudo code, using the infix operator `>>=` for `bind`:

```haskell
getComments =
  httpGet "/user" >>= \user → httpGet $ "comments/" <> user.id
```
So, instead of a `Task(Task([Comment])`, we have a nice `Task([Comment])` to work with in the next computation.

More formally, the type signature for `bind` is:

```
class Apply m <= Bind m where
  bind :: ∀ a b m. Bind m => m a → (a → m b) → m b
```

This reads - given the values or expressions `a` and `b` and a monad  `m` , such that `m` inherits the context from the type class `Bind`.  The function `bind`  takes the `a` out of `m`, then applies it to the function `a → m b` and returns `m b`.   One way of interpreting the phrase "inherits the context from the type class `Bind`", is that `bind` follows the `Apply` laws because `Bind` inherits the context from the type class `Apply` (click [here]( https://github.com/purescript/purescript-prelude/blob/v4.0.1/src/Control/Applicative.purs#L32-L33) for more detail).  What's interesting is that the instance for the `pure` operation, introduced in the last tutorial, belongs to the `Applicative` type class, which also inherits from the type class `Apply`:

```haskell
class Apply f <= Applicative f where
    pure :: ∀ a. a → f a
```
Now, putting it all together, the `Monad` type class combines the operations from the `Bind` and `Applicative` type classes, namely the `bind` and `pure` operations, respectively.   To be a true blue monad, it boils down essentially to three additional laws that a type constructor must follow.  The first is the law of associativity and the second and third are the left and right identity laws.  I'll discuss each of these laws below:

## Associativity law
For a type constructor, `m` to be a Monad, it must follow the law of associativity.  In simple terms, given a chain of monadic applications connected with `bind`, then it doesn't matter how they're nested.  More formally, `(m >>= f) >>= g  ≡ m >>= (\x → f x >>= g)`.  In the code example below, the way I prove this is with three functions, `m1`, `f` and `g`, where `f` and `g` are the identity function.  Remember that the identity function returns its input argument unmodified.  

```haskell
-- | Monad associativity law
-- | (m >>= f) >>= g ≡ m >>= (\x → f x >>= g)

m1 :: Box (Box (Box Int))
m1 = pure $ pure $ pure 3

-- | (m >>= f) >>= g
result1 :: Box Int
result1 = (m1 >>= identity) >>= identity

-- | m >>= (\x → f x >>= g)
result2 :: Box Int
result2 = m1 >>= (\x → identity x >>= identity)

-- | logs 'true' to the console
main = logShow $ result1 == result2
```
The function `result1` represents `(m >>= f) >>= g`.  By binding `m1` with the identity functions `f` and `g`, we can unnest `Box(Box(Box 3)` and transform it to `Box 3`.  Now, all we have to prove is that by shifting the parenthesis (i.e., `m >>= (\x → f x >>= g)`,  we're able to get the same `Box 3`; proven in the function `result2`.  What's interesting is that if the code above doesn't compile, then we don't have a Monad!  Because the identical type signatures representing `result1` and `result2`, implies that they must both return the same type.  Consider this your very first step toward [type-level programming](http://www.parsonsmatt.org/2017/04/26/basic_type_level_programming_in_haskell.html) with PureScript!

## Left & Right Identity laws
You may recall we had a couple of identity laws associated with Functors.  They prove that mapping over a Functor `f` with the identity function produces the same result as applying the identity function to the functor directly. In the case of monads, we have the Left and Right Identity laws to follow.  

The Left Identity law states that if you take a value and embed it into a type constructor with `pure`, then feed it to a type constructor using `bind`, then this process is the same as applying the type constructor directly.  More formally, `pure a >>= f ≡ f a`. So let's continue on our journey to prove that `Box` is a Monad with the next code example:

```haskell
-- | Left: pure a >>= f ≡ f a

m2 :: Box String
m2 = pure "Wonder"

leftIdentity :: Boolean
leftIdentity = (m2 >>= Box) == (Box "Wonder")

-- | logs 'true' to the console
main = logShow leftIdentity
```

Along these same lines, if we can show that `Box` adheres to the Right Identity law, then it must be a monad.  This law states that if you have a monad, `m` and you feed it to `pure` using `bind`, then this process is the same as the original monad.  More formally, `m >>= pure ≡ m`.  For the final code example, we'll do just that:

```haskell
-- | Right: m >>= pure ≡ m

m2 :: Box String
m2 = pure "Wonder"

rightIdentity :: Boolean
rightIdentity =  (m2 >>= pure) == m2

-- | logs 'true' to the console
main = logShow rightIdentity
```

And finally, after successfully proving the three monad laws, it is my great pleasure to confer `Box` with the prestigious Monad type class certification.  Thank you `Box` for your longtime service to functional programming and this tutorial.  Again, `Box` is also an Applicative Functor (a topic for an upcoming tutorial), and a Functor too.  Please have a look at the module `Data.Box` located in the [source directory](https://github.com/adkelley/javascript-to-purescript/tree/master/tut16/src/Data) of my repository.  There, you'll find the type class definition and instance declarations for `Box` which tells the compiler how to treat `Box` as a Functor, Applicative Functor, and Monad, using `map`, `pure`, and `bind`, respectively.

## Do notation
I hope you agree that the infix `bind` operator `>>=` is extremely useful in threading a value embedded in your monad onto its next computation.  It visually reminds me of a pipeline, where we transform the original value embedded in the monad with each computation along the chain.  However, chaining has its limitations in terms of readability; especially when you need to bind several computations to produce a result.  

For example, imagine you're tasked to write a custom video player for a front-end web application.  One of your user stories involves graphically updating the video player's progress bar.  At a minimum, you'll need to get two values from the HTMLMediaElement - the video's total time duration, and its [current time](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/currentTime).  Reading values from this API constitutes a side effect, so we must run these computations in the `Effect` monad.  If all we have is `>>=` in our toolbelt, then our code looks like this:

```haskell
handleProgress :: EventTarget → Element → Effect Unit
handleProgress video progressBar = 
  videoCurrentTime video >>= \currentTime → 
      videoDuration video >>= \duration → 
            updateProgressBar progressBar $ toString $ 
                   (currentTime / duration) * 100.0 
``` 

Frankly, I feel that this is about as far as I would code with the `bind` operator before my function becomes too difficult to read and understand. Just looking at the half pyramid above tells me there is likely a code smell. Fortunately, there is an alternative approach that makes these sequential bind operations much more readable, called `do` notation.  Once again, we've been using it throughout this series, particularly in our `main` functions.  In `main`, we're often processing the side effects (e.g., `log`) from multiple function calls, sequentially.  Take a look at our `main` function from this tutorial, for example.

Do notation or `do` blocks is a syntax sugar added to monadic expressions that help to turn code like the above into something much more readable:

```haskell
handleProgress :: EventTarget → Element → Effect Unit
handleProgress video progressBar = do
  currentTime ← videoCurrentTime video
  duration ← videoDuration video
  updateProgressBar progressBar $ 
    toString $ (currentTime / duration) * 100.0
```

First, we establish our `do` block with the keyword `do`.  Then, within the block, we can assign a variable name to a passed value using the single assignment operator `<-`.   So we assign the video's current time, and total duration to the variable names, `currentTime` and `duration`.   Finally, we update the video player's progress bar by calculating the percentage.

In summary, sequential computations within the context of a monad can be executed using a `do` block.  Moreover, you can expect to lean heavily on `do` blocks throughout your FP adventures, because it helps greatly with readability.  In constrast the `bind` operator `>>=`  is often reserved for one or two lines of code, especially when you need to name the argument for the next computation, as was shown in the video progress bar example above.

## Summary
In this tutorial, we covered monads in detail.  We learned that they are part of the Functor family, with a few more laws related to associativity and identity.  To chain or thread a value embedded within a monad to the next computation, we use the `bind` operator `>>=`.  This avoids nesting multiple type constructors of the same type.  Multiple binds can make our code difficult to read, so there is a syntax sugar called `do` notation that helps to make a sequence of monadic expressions look like that of any sequence of operations from an imperative language.  

I hope, after reading this tutorial, that you found monads to be an easy concept to master and an extremely useful type constructor. In the next tutorial, we'll see what it means to curry arguments in a function.  Again, it is something we've been doing throughout this series, but haven't had the opportunity to introduce it formally.   If you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media. Thank you and until next time!

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut15) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut17)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
