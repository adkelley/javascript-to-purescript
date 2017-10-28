# Capture Side Effects in a Task

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 12** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 11](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11)


Welcome to Tutorial 12 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we are going to the data structure Task, see some constructors, familiar methods, and finally how it captures side effects through laziness.  xxx, which is a technique for keeping your code pure, by deferring evaluation along with any side effects until it's time to return a value.  Lazy evaluation has a few more benefits as we'll see shortly.  We'll also look at how PureScript handles such things as type-safety and currying when transcompiling to JavaScript.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-delaying-evaluation-with-lazybox) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Mimicing Task with Continuation Passing Style

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
