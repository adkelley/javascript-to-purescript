# Capture Side Effects in a Task

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 12** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 11](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11) | [Tutorial 13 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13) [>> Tutorial 26](https://github.com/adkelley/javascript-to-purescript/tree/master/tut26)


## Introduction
Welcome to Tutorial 12 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we are going to create a structure called `Task` that mimics [data.task](http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task) from the [Folktale](http://folktalegithubio.readthedocs.io/en/latest/index.html) libraries developed for generic functional programming in JavaScript.  In Brian's [video tutorial](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task), he used `Task` from this library to show how, among other things, it can model side-effects explicitly within the structure through lazy evaluation (see [Tutorial 12]((https://medium.com/@kelleyalex/delay-evaluation-with-lazybox-4e71987ecc7a)).  This way, the programmer has full knowledge of and can encapsulate delayed computations, latency, or anything that isn't pure in one place.

## Modeling Task in PureScript
I should let you in on the punch line right up front - there is no explicit structure named `Task` in PureScript.  So, instead, we're going to model it ourselves using two approaches, Continuation Passing Style (CPS) and using the Asynchronous effect monad `Aff`, covering each in great detail.  We'll start with CPS for this tutorial and save `Aff` for the next, which fits perfectly with Brian's [subsequent tutorial](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions) on using `Task` for asynchronous actions.

## Continuation Passing Style (CPS)
Before we jump into modeling the `Task` structure using Continuation Passing Style (CPS), I'm not going to assume that you encountered this style of programming before.  So here's a little primer or perhaps a refresher for those who are already familiar with CPS.  

In functional programming, CPS is a style of programming functions that, instead of returning a result, passes it onto a *continuation*.  Here, a *continuation* is basically "what happens next" in the control flow.  A function written in CPS will take one extra argument, which is the continuation.  For example, it could be a continuation representing `success` or `failure`, similar to the `Either` constructor from [Tutorial 3](https://medium.com/@kelleyalex/tutorial-3-enforce-a-null-check-with-composable-code-branching-using-either-a73bacaec498).  If you watched Brian's [video](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task) (and you should), you saw how success and failure were represented by `Task.of` and `Task.rejected` respectively.

Now CPS is not only used for expressing a success or failure continuations, but you can also suspend a computation.  This approach keeps your code pure, by deferring evaluation along with any side effects until it's time to return a value.  We saw in Brian's video how he withheld the `fork` call to accomplish this suspension, suggesting the caller of our application do it.  This way, they're in charge of the fork, plus all the side-effects that go along with it.   We'll see an implementation of `fork` in our `Task` constructor examples shortly.  But first, I want to show some examples of CPS that I shamelessly copied from [Haskell/Continuation passing style](https://en.wikibooks.org/wiki/Haskell/Continuation_passing_style) and ported to PureScript.

I'll first show the *direct style* which is the opposite of CPS; the style in which we usually program.  I'll follow this direct style code with a solution using `continuations`, and finally there's a solution using the continuation monad, `Cont`.  Now we haven't covered monads, which is one of the most [confusing topics](https://wiki.haskell.org/What_a_Monad_is_not) in functional programming.  And I don’t want to address them at this time.  However, I would be negligent in not showing `Cont` to you now, because it helps to remove the long chains of nested lambdas we see in prototypical CPS, as shown below.

### Example: Pythagoras using direct style
```haskell
square :: Int -> Int
square x = x * x

pythagoras :: Int -> Int -> Int
pythagoras x y = add (square x) (square y)

main = log $ pythagoras 3 4
```
Hopefully, you will agree that this example requires no explanation.

### Example: Pythagoras using continuations
```haskell
addCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
addCPS x y = \k -> k (add x y)

squareCPS :: forall r. Int -> ((Int -> r) -> r)
squareCPS x = \k -> k (square x)

pythagorasCPS :: forall r. Int -> Int -> ((Int -> r) -> r)
pythagorasCPS x y = \k ->
  (squareCPS x) \xSquared ->
  (squareCPS y) \ySquared ->
  (addCPS xSquared ySquared) k

main =  pythagorasCPS 3 4 \k ->
    log $ "Pythagoras with continuations: " <> show k
```
Ok, there's a lot to unpack here.  First, in each of the CPS functions, notice the `((Int -> r) -> r)` in the type declaration.  This type represents a suspended computation, where the `(Int -> r)` argument is the continuation function, and the second `r` is its result.  It's how we bring the computation to a conclusion.


Let's work our way up this code listing, starting from `main`.  We call `pythagorasCPS 3 4`, putting the result into our top-level continuation function (`\k -> ...`); our side-effect that logs the result of `pythagorasCPS 3 4` to the console. Then:
1. square x and put the result  in the (`\xSquared -> ...`)  continuation
2. square y and put the result in the (`\ySquared -> ...`) continuation
3. add `xSquared` and `ySquared` and put the result in the top-level/program continuation `k`.

Whew!  Now, I know this is confusing to follow, and it indeed has taken me a good number of "head scratches" to get it finally.  "Is there a simpler way, without all those pesky nested lambdas," you ask?  Absolutely!  We can eliminate them using the Continuation monad:

### Example: Pyhagoras using Cont

```haskell
addCont :: forall r. Int -> Int -> Cont r Int
addCont x y =
  pure (add x y)

squareCont :: forall r. Int -> Cont r Int
squareCont x =
  pure (square x)

pythagorasCont :: forall r. Int -> Int -> Cont r Int
pythagorasCont x y = do
  xSquared <- squareCont x
  ySquared <- squareCont y
  addCont xSquared ySquared

main =  runCont (pythagorasCont 3 4) \k ->
    log $ "Pythagoras with Cont monad: " <> show k
```
Nice! Notice no more nested lamdas to confuse us.  Without opening the "monad pandora's box", perhaps the simplest way to describe what's happening here is that we compose all our continuation functions into `r`, wrapping this composition in the monad `Cont r Int`.  Then, the function `runCont` triggers the execution of `r`. When we execute `runCont (pythagorasCont 3 4)`, we provide it with our top-level continuation: (` \k -> ...`), which logs the type `Int` result of `pythagorasCont` to our console (note - we transformed the `Int` to a `String` using `show`).

So what is the advantage of using continuations in the above examples?  Well, depending on the circumstances, we've given ourselves the power to decide when and how to execute them, or perhaps never execute them at all!  Let me explain further - let's say we create a `success` continuation and a `failure` continuation, separately.  Based on the result of `pythagorasCont`, we cBased on the result of pythagorasCont, we can decide when and how to invoke the appropriate success or failure continuation.  And we'll do just that in the next example.

## Mimicking Task using CPS in PureScript
Now that we've covered continuation passing style (CPS), we have the tools necessary to emulate the [`Task`](http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task) constructor from the Folktale suite of libraries, that Brian used in his [tutorial video](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task).  In this tutorial, I've implemented `Task` as a type synonym for `Either`, which we covered in [Tutorial 3](https://medium.com/@kelleyalex/tutorial-3-enforce-a-null-check-with-composable-code-branching-using-either-a73bacaec498).  
Thus implicitly, `taskRejected` and `taskOf` are the `Left` and `Right` constructors from `Either`, which represent a *failed* or *successful* computation, respectively.  Let's take a look at the first code example below. If you would like to see my implementations of the task functions (e.g., taskOf) then you’ll find them in my github repository [here](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12/src/Data).

### Example: taskOf and taskRejected

```haskell
main = 
  let err = \e -> "error: " <> show e
  let success = \x -> "success: " <> show x
  let fork = (taskFork err success) 
  let k = (fork >>> log) 
  
  let c = contTask $ taskOf 1.0
  runCont c k
  let c = contTask $ taskRejected 1.0
  runCont c k
```
Let's take it from the top - `err`, and `success` are two separate continuation functions, one of which will be invoked by `k`, our top-level continuation.  Within `k`, notice we are composing `taskFork ` with `log`.   It's the job of `taskFork` to execute either the `err` or `success` continuation based on whether the `Task` continuation `r` produced a `Left` or `Right` constructor. Thus if my `Task` has successfully computed something, then `taskFork` will invoke the `success` continuation.  

In these simple examples `taskOf` and `taskRejected` do nothing more than to construct a `Right a` or `Left a`, respectively.  It's `contTask` that throws the `Task` into our continuation monad `Cont r (Task a b)`.  Then, when we're ready to run this continuation, we invoke `runCont c k` giving it the continuation monad `c` and our top-level continuation `k`.


### Example: taskOf.map

Alright, let’s take it up a notch, by showing how we can map over a Task, just like other 'container' types.

```haskell
  -- add a prefix string 'p' to our top-level continuation 'k'
  let k p = fork >>> \s -> log $ p <> s

  let c = contTask $ (taskOf 1.0) # map (_ + 1.0) 
  runCont c (k "taskOf.map: ")
```

### Example: taskOf.map.chain.taskOf

We can also bind (`>>=`) (aka `chain`) over it to return a Task within a Task:

```haskell
  let c = contTask $
              (taskOf 1.0) #
              map (_ + 1.0) >>=
               \x -> taskOf (x + 1.0)
  runCont c (k "taskOf.map.chain.taskOf: ")
```

Just like `Either`, if we return the rejected version of Task (i.e., `Left (some value) `), it will short circuit, ignoring map, bind, and the second task in the example below. Thus `k` will invoke the `err` continuation.

### Example: taskRejected.map.chain.taskOf

```haskell
  let c = contTask $
              (taskRejected 1.0) #
              map (_ + 1.0) >>=
              \x -> taskOf (x + 1.0)
  runCont c (k "taskRejected.map.chain.taskOf: ")
```

## Let's launch some missiles!
The final example in Brian's tutorial showed how you could leave it to the caller to fork the task so that they're in charge of the disposition of any side effects.  In fact, we've been doing this all along, thanks to `contTask` and `runCont`.  Take a look at the example below, and you'll see what I mean.

### Example: Taking control of any side-effects 
```haskell
  let err = \e -> "error: " <> e
  let success = \x -> "success: " <> x
  let fork = taskFork err success
 
  let t1 = taskOf "missile" # map (_ <> "!")
  let c = contTask $ t1 # map (_ <> "!") 
  let sideEffects = \t -> do
         log "launch missiles!"
         log t
  runCont c (fork >>> sideEffects)
```
Here we needed new `success` and `error` continuations because, this time we're returning a `String`, instead of an `Int`. I compose my set of continuation functions using `contTask`, and, at this stage, I can even extend the original Task with another computation, as shown above.  It's when we execute `runCont c k` that we finally run the computation `c` and witness the side-effects to the console with `k`.

## Summary
In this tutorial, we looked at how to capture any side-effects that may be lurking within our program into a Task.  This way, we have the power to witness these side-effects at will, or even alter the flow of our computation when we wish to act on them differently (see `taskFork` above).  There is no native `Task` structure in PureScript, so I showed how to emulate it using continuation passing style (CPS) of programming.

In CPS, functions don't return values; instead, they pass control to a *continuation*, which specifies what happens next in our computation.  In particular, I showed the best way to express CPS is with the monad `Cont r a` which is a type used to wrap our suspended computations `r`, and the resulting type from this suspended computation will be `a`.  When we're ready to run these suspended computations, we invoke `runCont c k`, where c is the continuation monad of type `Cont r a` (i.e., our suspended computations) and 'k' is our top-level/program continuation function.

Once again, whether or not you’re finding these tutorials helpful in making the leap from JavaScript to PureScript then give me a clap, star my [GitHub](https://github.com/adkelley/javascript-to-purescript/tree/master)  repository, drop me a comment, or post a [tweet](https://twitter.com/adkelley). I believe any feedback is good feedback and helpful toward making these tutorials better in the future. That’s all for this blog post.  Till next time, when we’ll delve deeper into capturing asynchronous side effects with another implementation of `Task`.

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I typically amend them as I write the accompanying tutorial markdown.  
