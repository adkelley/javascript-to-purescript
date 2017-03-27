# Refactor imperative code to a single composed expression using Box (DRAFT)

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 2** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-week. So come back often, there’s a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) | [> Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)

The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video already before tackling the abstraction in PureScript.  Brian covers the featured abstraction extremely well, and I feel it's better to understand its implementation in the comfort of JavaScript.  For this tutorial, the abstraction is Box( ) covered in [video1](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box). Note that the Box( ) abstraction is better known as the 'Identity' functor in swanky FP circles.  

One more time with feeling - You should be already somewhat familiar with the **Box** abstraction. You're also able to enter `bower update && pulp run` and `pulp run` after that, to load the library dependencies, compile the program, and run the PureScript code example.  **Finally**, if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02). Let's go!


## Navigation
[<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) | [> Tutorial 3 ](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)

This README is currently under construction. But if would like to look at the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) they have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
