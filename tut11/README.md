# Delay Evaluation with LazyBox

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial11** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 10](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10)

Welcome to Tutorial 11 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  TKL - What are we doing in this tutorial?

Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-unboxing-things-with-foldable) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Lazy Box
* Revisit our Box data structure from Tutorial 2.
  - Review what it did
  show the code example
* We're going to make our Box a lazy box
  - What is lazy evaluation?
  - Why would we want to do it?
  - How its done in PS with Lazy
  
We're going to take our Box data structure out for another spin, but with a twist.

A lazy value is computed at most once - the result is saved after the first computation, and subsequent attempts to read the value simply return the saved value.
Lazy values can be created with defer, or by using the provided type class instances.
Lazy values can be evaluated by using the force function.

## You should write some tests
* Unit Tests
  - [purescript-test-unit](https://pursuit.purescript.org/packages/purescript-test-unit/13.0.0/docs/Test.Unit)
* [purescript-spec](https://pursuit.purescript.org/packages/purescript-spec/1.0.0/docs/Test.Spec.Runner.Event)
  - [documentation](http://purescript-spec.wickstrom.tech/)

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
