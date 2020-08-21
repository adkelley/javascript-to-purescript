# Make the Leap from JavaScript to PureScript

![series banner](resources/glitched-abstract.jpg)

> *Note: This is the introduction to the “Make the Leap from JavaScript to PureScript” tutorial series.*
>
> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/md) | [> Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) [>> Tutorial 27](https://github.com/adkelley/javascript-to-purescript/tree/master/tut27)

## Introduction

"Make the Leap from JavaScript to PureScript" takes some of the most popular functional programming (FP) abstractions in JavaScript and demonstrates how to implement them in [PureScript](http://www.purescript.org). I borrowed the series outline and JavaScript code samples with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean).  I want to thank Brian (an enthusiastic coder of PureScript) for supporting this project.


Over the last few months, I've noticed a few curious JavaScript coders popping in on the PureScript forums (e.g., [gitter.im](https://gitter.im/purescript/purescript)) to ask about FP and PureScript.  In response, seasoned functional programmers have been highly recommending Brian's course, as a first step in becoming acquainted with FP. Then, once they understand the fundamental abstractions from the comfort of JavaScript, they're encouraged to come back and begin working with PureScript.  I can't agree more with this recommendation!  It is hard enough to learn the FP abstractions AND a new programming language at the same time.  But, in time, if you stick with FP in JavaScript, then you'll likely find that it is hard not to stray, and then you're right back to your old and imperative ways. Alternatively, PureScript is a true-blue FP language that compiles to JavaScript!  So I've written these tutorials to help you to cross over from JavaScript to PureScript by showing you how to implement the same concepts taught in Brian's course.

### Navigating your way

If you're new to FP or you haven't tackled Brian's course, then I highly recommend that first (I certainly did, and it helped me a lot). Then, once you understand the fundamental abstractions, come back, and I'll show you them in PureScript. I've done my best to explain the concepts, but Brian is a master at teaching them.  Also, these tutorials are not a replacement for a good old fashioned [PureScript primer](https://leanpub.com/purescript). So take the time to learn a little PureScript syntax before diving headfirst into these tutorials.

## Advantages of using PureScript in place of JavaScript

You can breathe easy knowing that JavaScript supports some of the most important features of FP, including first-class & anonymous functions and closures.  However, JavaScript has to serve more than one master, including object-oriented and imperative programming.  As a consequence, there are limitations and compromises when using JavaScript for FP. In particular, it is missing a static type system, enforced purity, and immutability.  Some of these gaps can be mitigated by adding a static type checker (see [TypeScript](https://www.typescriptlang.org/)), immutable collections (see [Immutable.js](https://facebook.github.io/immutable-js/)), and FP abstraction libraries (see [RamdaJS](http://ramdajs.com)). Still, you accomplish FP in JavaScript mostly by convention, often cobbling it together with the 'band-aids' I mentioned above. A functional JavaScript programmer must stay sharp at all times to create pure functions that avoid side effects.  But I believe this puts too much cognitive load on the programmer, and ultimately it interferes with coding your application.  Thankfully there are proper FP languages that eliminate this friction while compiling to optimized JavaScript - did anyone say PureScript?

PureScript has been architected solely as an FP language. It is a small, strongly typed language that compiles to human-readable [CommonJS](https://en.wikipedia.org/wiki/CommonJS), and other [languages](https://github.com/andyarvanitis/purescript-native) too. So you've got both client and server-side applications covered in one language - which doesn't get any better IMHO! You'll also find a representation of all the FP language constructs that you've either heard or read about, including currying, pattern matching, tail-call optimization, higher-order, and higher kinded types.  Finally, PureScript has no runtime system to add to your download footprint, and (**drum roll please**) there is an uncomplicated but very capable FFI to and from JavaScript! So if you don't find support yet for functions from your favorite JavaScript module, then it is not hard to include them yourself (and I'll show you some examples in the tutorials).

## Tutorial Layout

I've created a GitHub repository with the markdown versions of these stories (i.e., README.md) together with the code samples. You can clone it [here](https://github.com/adkelley/javascript-to-purescript) and [fetch upstream](https://help.github.com/articles/syncing-a-fork/) for future updates.

Each tutorial has been placed in a separate folder named 'tut##', where ## is a number (e.g., 'tut01') that corresponds to video## from Brian's [course](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript). There is the accompanying tutorial markdown (e.g., tut01/README.md)here, which illustrates the abstraction from Brian's corresponding video (e.g., video1) and how to implement it in PureScript.

I have set up the folders so that you can run the PureScript code samples for the first time with `npm run all` then `npm run exec` from thereon. There's also individual scripts `npm run clean`, `npm run install`, `npm run build`, and `npm run exec`; used to clean, install, build, and execute the tutorial examples respectively. Naturally, this assumes you have the `npm` package manager installed. These scripts also depend on `rimraf` (the UNIX command `rm -rf` for node), and `Spago` (PureScript's package manager and build tool). I explain all of this below.

## Get up and running in PureScript

You can skip this section if you've already installed Spago and are using version 0.13.x PureScript on your computer.

### Install PureScript and its supporting actors
In earlier versions of this tutorial, I recommended that you use the `Psc-Package` package manager and, preceding that, [Bower](https://bower.io). You'll still see these artifacts in many PureScript modules.  But, as of this tutorial revision, the PureScript community has now settled on the [Spago](https://github.com/purescript/spago) package manager and build tool.  Spago is the recommendation given in [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/), which I recommend you read thoroughly before proceeding further. In my experience so far, Spago is a welcome addition to PureScript's tooling, providing a great UX, with minimal dependencies and reproducible builds.

Assuming you already have npm running on your machine, here's how to install PureScript together with its development environment.   Before executing the following command, be sure you have the latest [npm](https://www.npmjs.com/) package manager and [node](https://nodejs.org/en/) installed.
`"
npm i -g purescript spago rimraf
`"
You can check that the installation was successful by trying these commands:
`"
spago version
purs --version
`"

### Install  editor plugins
There are plugins for most editors to support syntax highlighting, build support, REPL (Read, Evaluate, Print, Loop), and autocomplete. You'll find the information to install these plugins for your favorite editor [here](https://github.com/purescript/documentation/blob/master/ecosystem/Editor-and-tool-support.md).

### Run your first PureScript program

Assuming you've installed PureScript and Spago, then it doesn't get any easier than this to start your adventure in functional programming with PureScript:

`"
$ mkdir purescript-hello
$ cd purescript-hello
$ spago init
$ spago build
$ spago run
`"


### My Favorite PureScript tools & references

1. [PureScript by Example](https://book.purescript.org) is the official PureScript book, originally by Phil Freeman (the author of the PureScript language) and now maintained by the community.
2. [Pursuit](https://pursuit.purescript.org) is the home of PureScript documentation; soon to become your best friend
3. [Try PureScript](http://try.purescript.org/) allows you to try key examples of PureScript in the browser.  You can also create your own.
4. psc-ide (distributed with the compiler) provides editor support, including [atom](https://github.com/nwolverson/atom-ide-purescript), [emacs]( https://github.com/epost/psc-ide-emacs), [vim](https://github.com/FrigoEU/psc-ide-vim), and [visual studio]( https://github.com/nwolverson/vscode-ide-purescript)
5. [Discourse](https://discourse.purescript.org/) for discussing PureScript.
6.  [FP Slack](https://functionalprogramming.slack.com/#/) has a #purescript and #purescript-beginners channel.

## Onward!

[> Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01)

I'll add additional links as I write the tutorials. But If you would like to look ahead, then the majority of the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) are available on [Github](https://github.com/adkelley/javascript-to-purescript). But I may amend them as I write the accompanying tutorial markdown.  

*Edited on May 8, 2020, to support the Spago package manager and introduce the latest PureScript resources*
