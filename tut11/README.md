# Delay Evaluation with LazyBox

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial 11** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 10](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10) | [Tutorial 12 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12) [>> Tutorial 22](https://github.com/adkelley/javascript-to-purescript/tree/master/tut22)


Welcome to Tutorial 11 in the series **Make the leap from Javascript to PureScript**.  I hope you're enjoying it thus far.  If you're new to this series, then be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript.

In this tutorial, we are going to cover Lazy evaluation, which is a technique for keeping your code pure, by deferring evaluation along with any side effects until it's time to return a value.  Lazy evaluation has a few more benefits as we'll see shortly.  We'll also look at how PureScript handles such things as type-safety and currying when transcompiling to JavaScript.

I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-delaying-evaluation-with-lazybox) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts exceptionally well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

## Lazy evaluation
Lazy evaluation, also known as `call by need`, is a program execution model that defers the computation of expressions in your program until you need them.  Also, when you evaluate a lazy expression, the result is often "memoized" to ensure that it is computed only once.  Meaning, if the value is required again later in your program then, instead of re-evaluating it, the runtime will access the stored result from cache.

As you might imagine, this approach can reduce the running time of a function because it avoids repeated evaluations.  Another advantage is that you can take data structures, such as an array, and assume their range is infinite.  Then, generate as many items as you need from the sequence without expressly bothering about its size.

The opposite approach is called `strict evaluation`, also known as `call by value` or `eager evaluation`.  Let's look at strict evaluation using a trivial example in JavaScript.
```javascript
const f = (x, y)  => {
   return  2 * x
}

> f(5, 2 + 3)
< 10
```
Notice that `f` disregards the argument `y` in this function.  Regardless, Javascript uses strict evaluation, and therefore it will waste some amount of CPU cycles (albeit minuscule) on evaluating and binding `2 + 3` to `y` before calling `f`.  But in "lazy" languages such as Haskell, their compilers are usually smart enough to recognize that `f` doesn't need `y` to return its result, and therefore will avoid wasting time on this computation.

### PureScript is "eager" to please
PureScript takes on the default characteristics of its target language, in this case JavaScript, by employing strict evaluation.  Now don’t take my word for it, let's look at the transcompiled code from the following PureScript example.  You should again notice that `f` does not use the argument `y` in the computation.

```haskell
f :: Int -> Int -> Int
f x y = 2 * x

main =
   logShow $ f 5 (2 + 3)
```
Transcompiled to JavaScript:
```javascript
var f = function (x) {
    return function (y) {
        return 2 * x | 0;
    };
};

var main =
  Effect_Console.logShow(Data_Show.showInt)(f(5)(2 + 3 | 0));
```

As shown above, despite never using `y`, `main` will still evaluate `2 + 3` before calling `f`.  However, this should not be setting off alarm bells.  In fact, nearly all programming languages are strict, with one notable exception being Haskell.  There are some advantages because optimization for eager languages is common amongst modern hardware architectures.  Even the best compilers for lazy languages will likely produce slower code.  If it is eager, then the developer gets to decide about the order of execution of their program.  But this is somewhat of a grey area because modern compilers will naturally look for efficiencies, including reordering of expressions to best optimize processor resources.


There are a few more details in the transcompiled code example that deserve a further explanation; namely the bitwise OR operation (e.g., `return 2 * x | 0`)  and currying.  First I'll cover the purpose of performing the Bitwise OR operation,  then I'll talk a little about currying, saving the bulk of this subject for Tutorial 17.

### Ensuring that an Int is an Int
Notice in the PureScript example above, that the two arguments `x` and `y` to the function `f` are of type `Int`, and that `f` will also return a value of type `Int`.  By performing a bitwise OR operation on the input argument `y` and the return value from `f`, the PureScript compiler provides a guarantee within the transcompiled JavaScript that the resulting type will be a 32-bit signed integer (`Int`).  Here's a concrete example:
```javascript
var x = 113.45 | 0;   // becomes 113
var y = 11.12  | 0;     // becomes 11
```

### Currying
The second topic of interest from the transcompiled code above is currying.  Again, we'll save this subject for Tutorial 17. But, in short, when there are multiple arguments to a function, PureScript will transcompile it to JavaScript as a sequence of nested functions. Each will take one argument and return the next function or, in the case of the last one, give back the final result.  This nesting of functions is called `currying`, and it is a cornerstone of functional programming.

## Lazy Box example
We've covered the difference between "lazy" and "strict" evaluation, so let's move to the main code example.  From Brian's [video](https://egghead.io/lessons/javascript-delaying-evaluation-with-lazybox) you saw how to take our original `Box` type from [Tutorial 1](https://github.com/adkelley/javascript-to-purescript/blob/master/tut01/README.md), and make it "lazy" with just a few modifications:
```javascript
const LazyBox = g =>
({
   fold:   f => f(g()),
   map:  f => LazyBox(() => f(g(())))
   inspect: () =>  `LazyBox(${g()})`
})

const result = LazyBox(() =>  '     64    ')
               .map(abba => abba.trim())
               .map(trimmed => new Number(trimmed))
               .map(number => number + 1)
               .map(x => String.fromCharCode(x))
               .fold(x => x.toLowerCase())
```

So, how is this accomplished in PureScript?  Well, when it comes to lazy evaluation, there is no need to define it ourselves.  Instead, there is the `Lazy` class, which represents types that allow the evaluation of values to be deferred.  Moreover, its comes chalk full of instances including `map`.  So we can quickly port `LazyBox` to `Lazy` in PureScript with the following code example:
```haskell
import Data.Lazy (Lazy, defer, force)

nextCharForNumberString :: String -> Lazy String
nextCharForNumberString str =
  defer (\_ -> str) #
  map trim #
  map (\s -> fromMaybe 0 $ fromString s) #
  map (_ + 1) #
  map (\i -> fromCharCode i) #
  map (\c -> toLower $ unsafeCoerce c :: String)

main = do
  let lazyVal= nextCharForNumberString "     64   "
  logShow lazyVal
  log $ force lazyVal -- a
```
Besides the `Lazy` class, the two functions you should understand are `defer` and `force`.  The `defer` function does what you expect.  Just like our JavaScript example, it creates a Lazy value by assigning the concrete type `a` to an anonymous function.  The type signature for `defer` is:
```haskell
defer :: forall a. (Unit -> a) -> Lazy a
```
Brian mentions in his tutorial that this gives us "purity by virtue of laziness," because you'll never observe the effects by using `map` or any other instance belonging to the `Lazy` class until you apply `force`.  This delay in the evaluation of an expression is known as a `thunk`, a word that you'll often hear in functional programming.  The `force` function has the type signature:

```haskell
force :: forall a. Lazy a -> a
```

and it is analogous to `fold` in the JavaScript example because it "forces" (get it) the evaluation of all of the expressions recorded in `lazyVal` from `nextCharForNumberString`.

### Practical uses for Lazy
By far, the canonical example of lazy evaluation is working with infinite lists or arrays.  For example, it's nice that I can start creating a sequence of numbers, then take only the ones I need without worrying whether I generated too many or too little.  But, as you'll see below, it's not as concise to do this in PureScript as it is in Haskell, where sequence generation is lazy by default.  But alas it is possible!

The last time I encountered the need for `Lazy` was, of all things, solving [Problem 2](https://projecteuler.net/problem=2) in the Euler Project Series. It asks you to find the sum of even numbers in the Fibonacci sequence whose values do not exceed four million.  With Haskell being lazy, I was amazed at how easily I was able to solve this using `takeWhile`.  Here's the solution in Haskell:
```haskell
module Problem2 (solution) where

lazyFibSeq :: Integer -> Integer -> [Integer]
lazyFibSeq f1 f2 = f1 : lazyFibSeq f2 (f1 + f2)

solution :: Integer -> Integer
solution maxFib = sum $ filter even $ takeWhile (< maxFib) $ lazyFibSeq 1 2
```
Can I use the same code in PureScript? Well, sort of . . .

```haskell
module Problem2
  (solution) where

import Prelude

import Control.Lazy (defer)
import Data.Foldable (sum)
import Data.Int (even)
import Data.List.Lazy (List, filter, takeWhile, (:))


lazyFibList :: Int -> Int -> List Int
lazyFibList f1 f2 = f1 : defer \_ -> lazyFibList f2 (f1 + f2)

solution :: Int -> Int
solution maxFib = sum $ filter even $ takeWhile (_ < maxFib) $ lazyFibList 1 2

main = do
     log $ "Problem 2: " <> show (solution 4000000)
```

Nope, this is not as concise as my solution in Haskell.  Because PureScript is a strict language by default, I had to be more explicit using `defer` to tell PureScript that I wanted to lazily `cons` a list of Fibonacci numbers together.  If you're interested in looking at my solutions (1-8 so far) to the `Project Euler` problems you will find them in my [github account](https://github.com/adkelley/project-euler-purescript.git).  It's also an excellent example of how to create a test-suite in PureScript.

## I should write about writing tests!
Oh, I almost forgot, the dreaded tests.  Perhaps you thought you could avoid them because you heard that, similar to Haskell, "If a PureScript program compiles, then it probably works." Well, I experience this regularly, and it's a great feeling.  So yes - working in a strongly typed functional programming language mitigates writing tests for simple errors.  But it won’t help you to expose problems in your program's design or logic.  So, even in PureScript, you will still be required to write tests.  But hopefully, you'll enjoy writing them because you're testing for things that genuinely matter, instead of trivial things you can't avoid testing for when using JavaScript.

### There's more on this topic to come
In my last post, I mentioned that I would include a section on testing in this tutorial  What I didn't realize is that this topic deserves an entire tutorial of its own.  So that got me to thinking - there are many things about PureScript that I am interested in writing, but they don’t follow the outline of my "Make the Leap . . ." series.  Therefore, I am going to create individual posts about testing and other topics while "sticking to the script" for this series.   Stay tuned.

## Summary
In this tutorial, we looked at lazy and strict evaluation strategies and found that both JavaScript and PureScript are strict or eager by default.  But, with a little help from the `Lazy` class, including `defer` and `force`, we can evaluate expressions lazily in PureScript and even memoize them to avoid recalculation.  This delay in the evaluation of an expression is known as a `thunk`.

We learned that the two primary use cases for lazy evaluation are enforcing purity by delaying impure side effects and working with infinite lists or arrays.  You can generate data structures without knowing in advance as to how small or large they need to be.  We saw how that works in the Fibonacci sequence example, for solving Problem 2 from Project Euler.

We also solved the mystery of how the PureScript compiler ensures `Int` type signatures on arguments by using a bitwise OR operation before passing or returning values to and from a function.  Looking at some transcompiled code forced us to delve slightly into the concept of currying.  It is how PureScript turns multiple arguments to a function into a sequence of nested functions when transcompiling to JavaScript.  Currying is a cornerstone of functional programming, so be sure that you understand it.

Slightly off topic, but in most cases, you will find PureScript's transcompiled JavaScript code to be quite readable.  Therefore, I would encourage you to look under the covers to see how PureScript handles type-classes & instances, and other aspects you may be interested in knowing.

Once again, whether or not you’re finding these tutorials helpful in making the leap from JavaScript to PureScript then give me a clap, drop me a comment, or post a tweet. My twitter handle is @adkelley. I believe any feedback is good feedback and helpful toward making these tutorials better in the future. That’s all for this blog post.  Till next time, when we'll delve deeper into capturing side effects through laziness.

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10) **Tutorials** [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut12)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.

---
20171022: Updated the PureScript example in the Practical uses for Lazy section to utilize [Sam Thomson's](https://medium.com/@samthomson) suggestion of [Control.Lazy.defer](https://pursuit.purescript.org/packages/purescript-control/3.3.0/docs/Control.Lazy#v:defer)
