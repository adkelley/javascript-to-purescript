# Tutorial Series - Make the Leap from JavaScript to PureScript (DRAFT)

## Introduction

This tutorial series takes some of the most popular functional programming (FP) abstractions in JavaScript and demonstrates how to implement them in [PureScript](http://www.purescript.org). The series outline and javascript code samples have been borrowed from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean).  I want to thank Brian (an ardent coder of PureScript & Haskell) for supporting this project.

### Motivation for this series

Over the last few months, I've noticed a few curious JavaScript coders popping in on the PureScript forums (e.g., [gitter.im](https://gitter.im/purescript/purescript)) to ask about FP and PureScript.  In response, seasoned functional programmers have been highly recommending Brian's course, as a first step in becoming acquainted with FP. Then, once they understand the basic abstractions from the comfort of familiar JavaScript, they're encouraged to come back and begin working with PureScript.  I can't agree more with this recommendation!  Its hard enough to learn the FP abstractions AND a new programming language at the same time.  But, in time, if you stick with FP in JavaScript, then you're likely going to find that its easy to stray and you're right back to your old and imperative ways. PureScript is a true FP language that compiles to JavaScript!  So I've written these tutorials to help you to cross over from JavaScript to PureScript by showing you how to implement the same abstractions from Brian's course.

### Navigating your way

If you're new to FP or you haven't tackled Brian's course, then I highly recommend that you do that first (I certainly did, and it helped me a lot). Then, once you understand the basic abstractions, come back and I'll show you them in PureScript. I've done my best to explain the abstractions, but Brian is a master at teaching them.  Also, these tutorials are not a replacement for a good old fashioned [PureScript primer](https://leanpub.com/purescript). So take the time to learn a little PureScript syntax before diving head first into the tutorials in this series. You'll be happy you did.

## Advantages of using PureScript to replace JavaScript

We can all breathe easy knowing that JavaScript supports some of the most important features of FP (e.g., first class functions, `const`, and arrow functions).  However JavaScript has to serve more than one master, including object oriented and imperative programmers.  As a consequence, there are limitations and compromises when using JavaScript for FP. Its missing a static type system, purity, immutability, and even recursive tail call optimization.  Some of these gaps can be mitigated by adding a static type checker (see [Flow](https://github.com/facebook/flow)), immutable collections (see [Immutable.js](https://facebook.github.io/immutable-js/)), and FP abstraction libraries (see [RamdaJS](http://ramdajs.com)). Still FP in JavaScript is mostly accomplished by convention, often cobbled together with the 'bandaids' I mentioned above. A functional JavaScript programmer must be sharp at all times to create pure functions that avoid side effects.  But I believe this puts too much cognitive burden on the programmer, and ultimately interferes with solving their actual problem.  Thankfully there are proper FP language alternatives that eliminate this friction, while compiling to optimized JavaScript.

PureScript has been architected solely as a FP language. Its a small, strongly typed language that compiles to human readable [CommonJS](https://en.wikipedia.org/wiki/CommonJS), and other [languages](https://github.com/andyarvanitis/purescript-native) too. So you've got both the client side and server side covered in one language - which doesn't get any better IMHO!  You'll also find that all the FP language constructs that you've heard or read about are represented; including currying, pattern matching, tail call optimization, higher order and higher kinded types.  Finally PureScript has no runtime system to add to your customer's download footprint (sorry [Elm](http://elm-lang.org)), and plus (**drum roll please**) there is a simple and capable FFI to and from JavaScript (sorry again [Elm](http://elm-lang.org))! So if you don't find support yet for functions from your favorite JavaScript module, then its not hard to include them yourself (and I'll show you some examples in the tutorials).

## Tutorial Layout

Each tutorial has been placed in a separate folder named 'tut##', where ## is a number (e.g., 'tut01') that corresponds to video## from Brian's [course](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript). The folders have been set up so that you can run the PureScript code samples for the first time with `bower update && pulp run`, then `pulp run` from then on (explained below).  You will also find the accompanying tutorial markdown (e.g, tut01/README.md) which explains the abstraction from Brian's corresponding video (e.g. video1) and how its implemented in PureScript.

## Get up and running in PureScript

You can skip this section if you've already installed and are using PureScript on your computer.

### Install PureScript and its supporting actors
See [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/)

**;TLDR**

Seriously? You don't have 10-minutes to review the career changing [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/)? Well then I wash my hands or (as Japanese would have it, my feet) of all responsibility for the results:
```
npm install -g purescript pulp bower

```
### Run your first PureScript program

Assuming you've installed PureScript, Pulp, and Bower, then it doesn't get any easier than this to start your adventure in functional programming with PureScript:

```
$ mkdir purescript-hello
$ cd purescript-hello
$ pulp init
$ pulp run
```
[Pulp](https://github.com/bodil/pulp) is a great build tool with plenty of helper options; such as watching for source file updates and re-compiling them automatically. As you add more library dependencies to your program, you can install them with bower (e.g., `bower install purescript-lists --save`)


### My Favorite PureScript tools & references

1. [PureScript by Example](https://leanpub.com/purescript/) by Phil Freeman the author of the PureScript language
2. [Pursuit](https://pursuit.purescript.org) - the home of PureScript documentation; soon to become your best friend
3. psc-ide (distributed with the compiler) provides editor support, including [atom](https://github.com/nwolverson/atom-ide-purescript), [emacs]( https://github.com/epost/psc-ide-emacs), [vim](https://github.com/FrigoEU/psc-ide-vim), and [visual studio]( https://github.com/nwolverson/vscode-ide-purescript)

## So let's get this party started!

* [Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01)

I'll add additional links as I write the tutorial markdown. But If you would like to look ahead (e.g., [Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)), then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
