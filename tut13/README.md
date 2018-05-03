# Use Task for Asynchronous Actions

![Series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 13** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12)


## Introduction
Welcome to Tutorial 13 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.  The series outline and javascript code samples were borrowed with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his video before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and I feel it's better that you understand his implementation first, in the comfort of JavaScript.  

In this tutorial, we are going to refactor our structure `Task` from [Tutorial 12](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) so that it mimics a standard node callback style based workflow - minus the callbacks! If you recall, I mentioned we could implement [FolkTale] (http://folktalegithubio.readthedocs.io/en/latest/api/data/task/index.html?highlight=task)'s `Task` using two approaches.  The first is Continuation Passing Style (CPS) which we covered in the last tutorial and the second is using asynchronous computation, which we'll utilize in this tutorial.   I should also mention again that, unlike [Elm](http://package.elm-lang.org/packages/elm-lang/core/latest/Task) or FolkTale, there is no `Task` package or structure in PureScript.  We don't need it, because all of the functionality is available in PureScript already.  Instead, we piece it together into an abstraction, which I've done here.

We're going to lean heavily on the library [purescript-aff](https://pursuit.purescript.org/search?q=purescript-aff).  `Aff` stands for asynchronous effects,  and it allows us to write our programs as if we were writing synchronous code with effects.  But, behind the scenes, our program is operating asynchronously without any callbacks. Moreover, error handling is baked in, so we can use the functions from `Task` to deal with it the way we want.  If you've looked at this library and wondered how to put it into action, then this tutorial is for you! 

### Shout-Out!
But before we get started, I do want to give a shout-out to Ryan Rempel [rgrempel](https://github.com/rgrempel).  I hadn't used `Aff` before, so what I learned and drew inspiration from was his [purescript-elm-compat](https://github.com/rgrempel/purescript-elm-compat), and I essentially lifted his `Task` type structure verbatim.  Thank you, Ryan!  

### Housekeeping
In my [Tutorial 13 repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13), you'll find that, in addition to the new examples from Brian's [video](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions), I've rewritten the examples from Tutorial 12 to utilize `Aff`.  Let's get started by taking a step back to discuss how to write asynchronous programs in PureScript.

## Asynchronous programming in PureScript

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
