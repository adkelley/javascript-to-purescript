# Make the Leap from Javascript to PureScript (DRAFT)

## Introduction

This tutorial series takes the most popular functional programming (FP) abstractions in Javascript and demonstrates how to implement them in [PureScript](http://www.purescript.org). The series outline and javascript code samples have been borrowed from the egghead.io course [Professor Frisby Introduces Composable Functional Javascript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean).  I want to thank Brian (an ardent PureScript & Haskell fan) for supporting this project.

### Motivation for this series

Over the last few months, I've noticed a few curious and enlightened Javascript coders popping up in the PureScript forums e.g., [gitter.im](https://gitter.im/purescript/purescript) to ask about FP and PureScript.  Often, in response to their questions, seasoned functional programmers were highly recommending Brian's course as a first step in becoming acquainted with FP. Then, once they're familiar with the basic abstractions from the comfort of Javascript, they're encouraged
to come back and begin working with PureScript.  I've written these tutorials to help you accomplish that second step - you know Javascript, understand the basic concepts in FP, but have come recognize that there's too much cognitive load in accomplishing FP with Javascript.

### Navigating your way

If you're new to FP or you haven't tackled Brian's course, then I highly recommend that you do that first (I certainly did). Then, once you understand the basic abstractions, come back and I'll show you those same abstractions in PureScript. I've done my best to explain them, but Brian is a master at teaching them.  Finally, these tutorials are not a replacement for a good old fashioned [PureScript primer](https://leanpub.com/purescript). So take the time to learn a little PureScript syntax before diving head first into this series.

## Advantages of using PureScript in place of Javascript

Breathe easy knowing that Javascript supports some of the most important features of FP (e.g., first class functions).  But, besides FP, Javascript has to serve several masters, including object oriented and imperative programmers.  As a consequence, there are limitations and compromises when using Javascript for FP. In particular, its missing a type system, purity, immutability, and recursive tail call optimization.  Some of these gaps can be mitigated by adding a static type checker (see [Flow](https://github.com/facebook/flow)), immutable collections (see [Immutable.js](https://facebook.github.io/immutable-js/)), and FP abstraction libraries (see [RamdaJS](http://ramdajs.com)). And the Javascript ES6 standard has certainly delivered more FP goodness with the introduction of `const` and arrow functions `(x) => y`, just to name a few.  Still FP in Javascript is mostly accomplished by convention, along with cobbling together the 'bandaids' I mentioned above. A Javascript programmer must be always conscious to create pure functions that avoid side effects - it should always be front and center in their mind.  I believe this places too much cognitive load on the programmer; especially when there are proper FP languages that eliminate this friction, while compiling to optimized Javascript.

PureScript has been architected solely as a FP language. Its a small, strongly typed language that compiles to human readable [CommonJS](https://en.wikipedia.org/wiki/CommonJS), and other [languages](https://github.com/andyarvanitis/purescript-native) too. So you've got both your client side and server side covered in one language - which doesn't get any better IMHO!  You'll also find all the FP language features you've probably heard or read about, including currying, pattern matching, tail call optimization, higher order and higher kinded types.  Finally there is no runtime system that adds to your download footprint (sorry [Elm](http://elm-lang.org)), and plus (**drum roll please**) there is a very powerful and straight forward FFI to and from Javascript! So if you don't find support yet for functions from your favorite Javascript module, then its not hard to include them yourself (I'll show you some examples in the tutorials)

## Tutorial Layout

Each tutorial has been placed in a separate folder named 'tut##', where ## is a number (e.g., 'tut01') that corresponds to video## from Brian's [course](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript). The folders have been set up so that you can run the PureScript code samples for the first time with `bower update && pulp run`, then `pulp run` from then on (explained below).  You will also find the accompanying tutorial markdown (e.g, Create-linear-data-flow-with-container-style-types.md) which matches the titles from each of Brian's tutorials.  Here I explain the abstractions covered in Brian's corresponding video and how they are implemented in PureScript.

## Getting up and running in PureScript

You can skip this section if you've already installed and are using PureScript

### Installing PureScript and its supporting actors
See [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/)

**;TLDR**

Seriously? You don't have 10-minutes to review [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/)? Well you've been warned and I wash my hands or (as Japanese would have it, my feet) of all responsibility for the results:
```
npm install -g purescript pulp bower

```
### Running your first PureScript program

Assuming you've installed PureScript, Pulp, and Bower, then it doesn't get any easier than this:

```
$ mkdir purescript-hello
$ cd purescript-hello
$ pulp init
$ pulp run
```
[Pulp](https://github.com/bodil/pulp) is a great build tool with plenty of helper options; such as watching for source file updates and re-compiling them automatically. As you add more library dependencies to your program, you can install them with bower (e.g., `bower install purescript-lists --save`)

See [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/)

### My Favorite PureScript tools & references

1. [PureScript by Example](https://leanpub.com/purescript/) by Phil Freeman the author of the PureScript language
2. [Pursuit](https://pursuit.purescript.org) - the home of PureScript documentation; soon to become your best friend
3. psc-ide (distributed with the compiler) provides editor support, including [atom](https://github.com/nwolverson/atom-ide-purescript), [emacs]( https://github.com/epost/psc-ide-emacs), [vim](https://github.com/FrigoEU/psc-ide-vim), and [visual studio]( https://github.com/nwolverson/vscode-ide-purescript)

## Let's get this party started!

* [Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01)

I'll add additional links as I write the tutorial markdown. But If you would like to look ahead (e.g., [Tutorial 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut02)), then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
