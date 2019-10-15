# List comprehensions with Applicative Functors

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 20** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-month. So come back often, there’s a lot more to come!*

> [Index](https://github.com/adkeelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 19](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19) | [Tutorial 25 >>](https://github.com/adkelley/javascript-to-purescript/tree/master/tut25)

In the last tutorial, I introduced our first practical example of an Applicative Functor for getting a web page's screen height from the DOM.  In this tutorial, we'll continue covering them with another example that captures the pattern of nested loops in your imperative code when constructing list comprehensions. For a quick review of applicative functors, please read my [last tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19).  Alternatively, if you are new to the Applicative, then please start with [tutorial 18](https://github.com/adkelley/javascript-to-purescript/tree/master/tut18).

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you’ve watched his [video](https://egghead.io/lessons/javascript-list-comprehensions-with-applicative-functors) on the topic before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Also, before leaving, please give it star to help me publicize these tutorials.


## Foldable Comprehensions
Let's define this term by breaking it down - *Foldable* data structures are types which can be folded to a summary value (using `foldl` or `foldr`).  *Comprehensions* are type constructs for creating a new Foldable data structure from an existing one.  The most common foldable data structures are lists, arrays, and trees. In languages, such as python and CoffeeScript, there are syntactic constructs (see [python example](https://www.pythonforbeginners.com/basics/list-comprehensions-in-python)) available to a create a list comprehension.  Note that there was a [preliminary proposal](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Array_comprehensions) for array comprehensions in Javascript, but it never made it to ES6/ES2015.

For this tutorial, I'll follow Brian's lead by illustrating an example of a list comprehension. Again, be sure to review his [video](https://egghead.io/lessons/javascript-list-comprehensions-with-applicative-functors), so that you understand the context of what we're going to accomplish in this tutorial.  First, for lack of an array comprehension construct in Javascript, here's how you can create one using nested loops:

```javascript
const xs = ['teeshirt', 'sweater'];
const ys = ['large', 'medium', 'small'];
const clothes = [];

for (x of xs) {
  for (y of ys) {
    // ["teeshirt-large", "teeshirt-medium", ..."]
    clothes.push(`${x}-${y}`); 
  }
}
```
To add more elements to our comprehension, such as color in the example below, we create another inner loop:
```javascript
const zs = ['red', 'green', 'blue'];

for (x of xs) {
  for (y of ys) {
    for (z of zs) {
      // ["teeshirt-large-red", "teeshirt-medium-red", ..."]
      clothes.push(`${x}-${y}-$(z)`);
    };
  };
};
```

Add more nested loops at your peril, because it leads to code that is difficult to read and debug until it becomes a sinister [pyramid of doom](https://en.wikipedia.org/wiki/Pyramid_of_doom_(programming)).  So, the critical takeaway from Brian's tutorial and mine is to replace these messy loops altogether by using an applicative functor. Again, this pattern works on not only lists but any foldable data structure such as an array or tree.

## List comprehensions in PureScript
In purescript, we construct a List using a couple of functions provided by the [Data.List](https://pursuit.purescript.org/packages/purescript-lists/5.3.0/docs/Data.List) module from the `purescript-lists` package.

```haskell
import Data.List (List(..), (:))

newStringList :: String → List String
newStringList s = s : Nil
```

The new functions above are `cons`, whose infix operator is `(:)`, and `Nil` for representing the empty list.  In the above example, we are `cons`tructing a new list by prepending the string `s` to `Nil`. With these two functions, together with our applicative functor, we have the necessary ingredients for constructing a list comprehension of clothes, created from our type, size, and color lists:

```haskell
import Prelude
import Data.List (List(..), (:))

-- returns ('teeshirt-large-black' : 'teeshirt-large-white', ...)
merch1 :: List String
merch1 = (\x y z -> x <> "-" <> y <> "-" <> z)
  <$> ("teeshirt" : "sweater" : Nil)
  <*> ("large" : "medium" : "small": Nil)
  <*> ("black" : "white" : Nil)
```

### Using lift from Control.Apply

Now, you could argue that the above example is no more readable than our nested loops imperative code example.  I disagree, but for the sake of avoiding an argument, we can use `lift3` from `Control.Apply` to further help with readability.

```haskell
import Prelude
import Control.Apply (lift3)
import Data.List (List(..), (:))

merch2 :: List String
merch2 = lift3
  (\x y z → x <> "-" <> y <> "-" <> z)
  ("teeshirt" : "sweater" : Nil)
  ("large" : "medium" : "small" : Nil)
  ("black" : "white" : Nil)
```

We are using `lift3` in the above example to lift our function of three arguments (i.e., x, y and z) to a function which accepts and returns values wrapped in our `List` constructor.  If you look at the [source code](https://github.com/purescript/purescript-prelude/blob/v4.1.0/src/Control/Apply.purs#L67-L67) for `lift3`, you'll see that it is merely syntactic sugar that eliminates the need for `pure` and `(<*>)`, used in our first example. 

### Using Applicative Do

Once again, you may believe that `lift` is still not much better than using nested loops.  Ok, to appeal to your imperative mental model, let's make our applicative look a little more synchronous by borrowing from `do-notation`.  You may be aware that `do` blocks in functional programming behave like `;` in imperative languages, including JavaScript. We often use them as an alternative to monad bind syntax (e.g., `>>=`) when sequencing actions that run consecutively.

```haskell
merch3 :: List String
merch3 = ado
  x <- ("teeshirt" : "sweater" : Nil)
  y <- ("large" : "medium" : "small" : Nil)
  z <- ("black" : "white" : Nil)
  in (x <> "-" <> y <> "-" <> z)
```

With Applicative do-notation, introduced with the 0.12.0 compiler, PureScript adds support for desugaring do-notation into Applicative expressions where possible. However, under the hood, this block can be executed in parallel, since `x`, `y`, and `z` are independent of one another.  In contrast, we must execute Monad expressions in sequence, because determining the list of `y`s is dependent on computing the list of `x`s such that `List x → (x → List y) → List y`.  

The choice is yours whether to use one of the three syntax constructs shown above.  Naturally, they all accomplish the same result. So use whichever helps future readers of your code to understand the implementation of your logic better.


## Summary

In this tutorial, we covered a simple example of the power of the Applicative Functor for creating foldable comprehensions; eliminating those messy nested loops from imperative code.  PureScript supports several foldable data structures, including lists, arrays, and trees.  We can construct a list in PureScript using `cons` and `Nil` from the `Data.List` module in the `purescript-lists` package. 

For every argument in our applicative function, when we apply it to a `Foldable` we eliminate one loop within your imperative code.  For example, we can express a double loop pattern by the following applicative function.  This example is also a list comprehension because we are creating a new list `xys = (4 : 5 : 5 : 6 : Nil)` from the lists `xs = (1 : 2 : Nil)` and `ys = (3 : 4 : Nil)`.

```haskell
import Prelude
import Data.List (List(..), (:))

-- returns (4 : 5 : 5 : 6 : Nil)
doubleLoop :: List Int
doubleLoop = lift2 
  (\x y → x + y) 
  (1 : 2 : Nil) 
  (3 : 4 : Nil)
```

In summary, Applicative Functors effectively replace loop patterns from imperative programming.  In the next tutorial, I'll show you how to refactor some sequential code that uses monads to achieve concurrency by replacing them with applicatives. If you're enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on social media. Thank you and until next time!
