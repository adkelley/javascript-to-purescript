# Use chain for composable error handling with nested Eithers (DRAFT)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 4** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) | [> Tutorial 5](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript.  

In this tutorial, we refactor a function that uses try/catch to a single composed expression using Either. We then introduce the chain function to deal with nested Eithers resulting from two try/catch calls. (see [video4](https://egghead.io/lessons/javascript-composable-error-handling-with-either)) If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04).

## Introduction
It is fairly common to encounter nested `Either` functors in the wild.  For example, imagine your task is to read a configuration file to collect some information about how to run your program.  Alas, your computation will not be pure because there are side-effects to consider that are related to file IO.  So we're going to have to handle this side-effect.  More specifically, there are at least two possible errors that may occur.  The first is that, for whatever reason, you are unable to access the configuration file.  And secondly, while you may be successful in reading the file, the fields that you're looking for may be missing or incorrect. In any case, you decide that `Either` is the best functor to wrap and report possible errors back to the user

## Diving into the code


## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript)[< ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03) Tutorials [ >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then most the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
