# Make the Leap from JavaScript to PureScript

![series banner](resources/glitched-abstract.jpg)

> *Note: This is the introduction to the “Make the Leap from JavaScript to PureScript” tutorial series. I’ll be*
> *publishing a new tutorial approximately once-per-week. So come back often, there’s a lot more of this to come!*
>
> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/md) | [> Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01) [>> Tutorial 20](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20)

## Introduction

"Make the Leap from JavaScript to PureScript" takes some of the most popular functional programming (FP) abstractions in JavaScript and demonstrates how to implement them in [PureScript](http://www.purescript.org). I borrowed the series outline and JavaScript code samples with permission from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean).  I want to thank Brian (an enthusiastic coder of PureScript) for supporting this project.

### Motivation for this series

Over the last few months, I've noticed a few curious JavaScript coders popping in on the PureScript forums (e.g., [gitter.im](https://gitter.im/purescript/purescript)) to ask about FP and PureScript.  In response, seasoned functional programmers have been highly recommending Brian's course, as a first step in becoming acquainted with FP. Then, once they understand the basic abstractions from the comfort of JavaScript, they're encouraged to come back and begin working with PureScript.  I can't agree more with this recommendation!  It is hard enough to learn the FP abstractions AND a new programming language at the same time.  But, in time, if you stick with FP in JavaScript, then you'll likely find that it is easy to stray, and then you're right back to your old and imperative ways. Alternatively, PureScript is a true blue FP language that compiles to JavaScript!  So I've written these tutorials to help you to cross over from JavaScript to PureScript by showing you how to implement the same concepts taught in Brian's course.

### Navigating your way

If you're new to FP or you haven't tackled Brian's course, then I highly recommend that you do that first (I certainly did, and it helped me a lot). Then, once you understand the basic abstractions, come back and I'll show you them in PureScript. I've done my best to explain the concepts, but Brian is a master at teaching them.  Also, these tutorials are not a replacement for a good old fashioned [PureScript primer](https://leanpub.com/purescript). So take the time to learn a little PureScript syntax before diving head first into these tutorials.

## Advantages of using PureScript in place of JavaScript

You can breathe easy knowing that JavaScript supports some of the most important features of FP, including first class & anonymous functions and closures.  However, JavaScript has to serve more than one master, including object-oriented and imperative programming.  As a consequence, there are limitations and compromises when using JavaScript for FP. In particular, it is missing a static type system, enforced purity, and immutability.  Some of these gaps can be mitigated by adding a static type checker (see [Flow](https://github.com/facebook/flow)), immutable collections (see [Immutable.js](https://facebook.github.io/immutable-js/)), and FP abstraction libraries (see [RamdaJS](http://ramdajs.com)). Still, FP in JavaScript is mostly accomplished by convention, often cobbled together with the 'band-aids' I mentioned above. A functional JavaScript programmer must stay sharp at all times in order to create pure functions that avoid side effects.  But I believe this puts too much cognitive load on the programmer and ultimately it interferes with coding your application.  Thankfully there are proper FP languages that eliminate this friction while compiling to optimized JavaScript - did anyone say PureScript?

PureScript has been architected solely as an FP language. It is a small, strongly typed language that compiles to human readable [CommonJS](https://en.wikipedia.org/wiki/CommonJS), and other [languages](https://github.com/andyarvanitis/purescript-native) too. So you've got both client and server side applications covered in one language - which doesn't get any better IMHO!  You'll also find a representation of all the FP language constructs that you've either heard or read about; including currying, pattern matching, tail call optimization, higher order and higher kinded types.  Finally, PureScript has no runtime system to add to your download footprint, and plus (**drum roll please**) there is an uncomplicated but very capable FFI to and from JavaScript! So if you don't find support yet for functions from your favorite JavaScript module, then it is not hard to include them yourself (and I'll show you some examples in the tutorials).

## Tutorial Layout

I’ve created a github repository with the markdown versions of these stories (i.e., README.md) together with the code samples. You can clone it [here](https://github.com/adkelley/javascript-to-purescript) and [fetch upstream](https://help.github.com/articles/syncing-a-fork/) for future updates.

Each tutorial has been placed in a separate folder named 'tut##', where ## is a number (e.g., 'tut01') that corresponds to video## from Brian's [course](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript). You will also find the accompanying tutorial markdown (e.g., tut01/README.md) which illustrates the abstraction from Brian's corresponding video (e.g., video1) and how to implement it in PureScript.

I have set up the folders so that you can run the PureScript code samples for the first time with `npm run all` then `npm run exec` from there on. There's also individual scripts `npm run clean`, `npm run install`, `npm run build`, and `npm run exec`; used to clean, install, build, and execute the tutorial examples respectively. Naturally, this assumes you have (and you should) the `npm` package manager installed. These scripts depend on `rimraf` (the UNIX command `rm -rf` for node), `Pulp` (a build tool for PureScript projects), `Psc-Package` (PureScript package manager), and the `Bower` package manager.  Note that `Bower` is used in a couple of cases only. I will remove it, once `Psc-Package` captures all my module dependencies.  All this is explained below.

## Get up and running in PureScript

You can skip this section if you've already installed and are using version 0.12.x PureScript on your computer.

### Install PureScript and its supporting actors
In earlier versions of this tutorial, I recommended you use [Bower](https://bower.io) as your package manager.  In fact, this is recommendation given in [Getting Started with PureScript](http://www.purescript.org/learn/getting-started/).  Bower is useful, thanks to its flat dependency graph, and easy to use. However, its inability to restrict libraries that work with a specific compiler version of PureScript can cause problems for beginners.  Especially during the early stages of a release of the compiler when libraries, tooling, and documentation are still catching up.  

 Instead, I recommend you use PureScript's own `Psc-Package` manager. The installation and usage are just as simple using Bower, so I see no good reason to use Bower when it is not necessary.  Assuming you already have npm running on your machine, here's how to install PureScript, Pulp, and Psc-Package.  As of this writing, I recommend you use the 0.12.0 version of the compiler.  Before executing the following command, be sure you have the latest [npm](https://www.npmjs.com/) package manager and [node](https://nodejs.org/en/) installed.
```
npm i -g purescript@0.12.0 pulp psc-package bower rimraf
```
You can check that these work by trying some commands:
```
pulp --version
bower --version
psc-package
```

### Install  editor plugins
There are plugins for most editors to support syntax highlighting, build support, REPL (Read, Evaluate, Print, Loop), and autocomplete.  You'll find the information to install these plugins for your favorite editor [here](https://github.com/purescript/documentation/blob/master/ecosystem/Editor-and-tool-support.md).

### Run your first PureScript program

Assuming you've installed PureScript, Pulp, and Psc-Package, then it doesn't get any easier than this to start your adventure in functional programming with PureScript:

```
$ mkdir purescript-hello
$ cd purescript-hello
$ pulp --psc-package init
$ pulp run
```
[Pulp](https://github.com/bodil/pulp) is an excellent build tool with plenty of helper options; such as watching for source file updates and re-compiling them automatically. As you add more library dependencies to your program, you can install them with `psc-package` (e.g., `psc-package install <package>`).  You'll find more information on `psc-package`  [here](https://github.com/purescript/psc-package) 


### My Favorite PureScript tools & references

1. [PureScript by Example](https://leanpub.com/purescript/) by Phil Freeman the author of the PureScript language
2. [Pursuit](https://pursuit.purescript.org) is the home of PureScript documentation; soon to become your best friend
3. [Try PureScript](http://try.purescript.org/) allows you to try key examples of PureScript in the browser.  You can also create your own.
4. psc-ide (distributed with the compiler) provides editor support, including [atom](https://github.com/nwolverson/atom-ide-purescript), [emacs]( https://github.com/epost/psc-ide-emacs), [vim](https://github.com/FrigoEU/psc-ide-vim), and [visual studio]( https://github.com/nwolverson/vscode-ide-purescript)

## Onward!

[> Tutorial 1](https://github.com/adkelley/javascript-to-purescript/tree/master/tut01)

I'll add additional links as I write the tutorials. But If you would like to look ahead, then the majority of the code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) are available on [Github](https://github.com/adkelley/javascript-to-purescript). But I may amend them as I write the accompanying tutorial markdown.  
