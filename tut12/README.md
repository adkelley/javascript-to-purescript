# Capture Side Effects in a Task

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 12** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 11](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11)


## Introduction
Welcome to Tutorial 12 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-delaying-evaluation-with-lazybox) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

In this tutorial, we are going to create a structure called `Task` that mimics [data.task](http://docs.folktalejs.org/en/latest/api/data/task/index.html) from the [Folktale](http://docs.folktalejs.org/en/latest/index.html) libraries developed for generic functional programming in JavaScript.  In Brian's [video tutorial](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task), he used `Task` from this library to show how, among other things, it can model side-effects explicitly within the structure through lazy evaluation (footnote) (see [Tutorial 12]((https://medium.com/@kelleyalex/delay-evaluation-with-lazybox-4e71987ecc7a)).  This way, the programmer has full knowledge of and can encapsulate delayed computations, latency, or anything that isn't pure in one place.

## Modeling Task in PureScript
I should let you in on the punch line right up front - there is no explicit structure named `Task` in PureScript.  So, instead, we're going to model it ourselves using two approaches, Continuation Passing Style (CPS) and using the Asynchronous effect monad `Aff`, covering each in great detail.  We'll start with CPS for this tutorial and save `Aff` for the next, which fits perfectly with Brian's [subsequent tutorial](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions) on using `Task` for asynchronous actions.

## Continuation Passing Style (CPS)
Before we jump into modeling the `Task` structure using CPS, I'm not going to assume that you encountered this style of programming before.  So here's a little primer or perhaps a refresher for those who are already familiar with CPS.  

In functional programming, CPS is a style of programming functions that, instead of returning a result, pass it onto a `continuation`.  Here, a `continuation` is basically "what happens next" in the control flow.  A function written in CPS style will take one extra argument, which is the continuation.  For example, it could be a continuation representing `success` or `failure`, similar to the `Either` constructor from [Tutorial 3](https://medium.com/@kelleyalex/tutorial-3-enforce-a-null-check-with-composable-code-branching-using-either-a73bacaec498).  
If you watched Brian's [video](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task) (and you should), you saw how success and failure were represented by `Task.of` and `Task.rejected` respectively.

Now CPS is not only used for expressing a success or failure continuation, but you can also to suspend a computation.  This approach keeps your code pure, by deferring evaluation along with any side effects until it's time to return a value.  We saw in Brian video how he withheld the `fork` call to accomplish this suspension, suggesting the caller of our application do it.  This way, they're in charge of the fork, plus all the side-effects that go along with it.   We'll see implement `fork` in our `Task` constructor shortly.  But first, I want to show some examples of CPS that I shamelessly copied from [Haskell/Continuation passing style](https://en.wikibooks.org/wiki/Haskell/Continuation_passing_style) and ported to PureScript.

In each of the code snippets below, I'll first show the `direct style` which is opposite of CPS and the style in which we usually program.  We follow the direct style code with the solution using `continuations`, and finally there's the solution using the continuation monad, `Cont`.  Now we haven't covered monads, one of the most [confusing topics](https://wiki.haskell.org/What_a_Monad_is_not) in functional programming, and I don’t want to address them at this time.  However, I would be negligent in not showing `Cont` to you now, because it helps to remove the long chains of nested lambdas using prototypical CPS, as you’re going to see.  But again, we'll save the topic of monads for another tutorial.

## Mimicing Task with Continuation Passing Style

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
