# List comprehensions with Applicative Functors

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 19** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I’ll be publishing a new tutorial approximately*
> *once-per-month. So come back often, there’s a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 19](https://github.com/adkelley/javascript-to-purescript/tree/master/tut19)

In the last tutorial, I laid out an example of the applicative functor that accessed a web page's screen height from the DOM.  In this tutorial, we'll continue covering the applicative functor with another example that captures the pattern of nested loops in imperative code when constructing foldable comprehensions, such as a list or array. For a quick applicative functor review, please read my [last tutoria]() or, if your starting from scratch on applicatives then start with the [previous one]()

I borrowed this series outline, and the javascript code samples with permission from the egghead.io course Professor Frisby Introduces Composable Functional JavaScript by Brian Lonsdorf — thank you, Brian! A fundamental assumption of each tutorial is that you’ve watched his [video](https://egghead.io/lessons/javascript-list-comprehensions-with-applicative-functors) before tackling the equivalent PureScript abstraction featured in this tutorial. Brian covers the featured concepts exceptionally well, and I feel it’s better that you understand its implementation in the comfort of JavaScript.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut20).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.


## Foldable Comprehensions
Let's break this down - *Foldable* data structures are types which can be folded to a summary value (using `foldl` or `foldr`) and *Comprehensions* are type constructs for creating a new Foldable data structure from an exsiting one.  The most common foldable data structures are lists, arrays, and trees. In languages, such as python and coffeescript, there are syntactic constructs ([python example](https://www.pythonforbeginners.com/basics/list-comprehensions-in-python)) available to a create a list comprehension.  In fact, there was an [experimental proposal](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Array_comprehensions) for array comprehensions in Javascript, but it never made it to ES6/ES2015.

For this tutorial, I'll follow Brian's lead by illustrating an example of a foldable comprehension using a list. However my approach using the applicative functor will work on any foldable data structure.  First, for lack of a comprehension construct in Javascript, I'll show an example using nested loops to illustrate what we're trying to accomplish.

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
To add another element to our comprehension, such as color, we create another inner loop:
```javascript
const zs = ['red', 'green', 'blue'];

for (x of xs) {
  for (y of ys) {
    for (z of zs) {
      // ["teeshirt-large-red", "teeshirt-medium-red", ..."]
      clothes.push(`${x}-${y}-$(z)`);
    }
  }
}
```

Now adding further levels of nested loops quickly leads to what is commonly called the [pyramid of doom](https://en.wikipedia.org/wiki/Pyramid_of_doom_(programming). Do this at your peril, because is difficult to read and debug. However, in functional programming, we avoid these messy loops altogether, with the applicative functor playing a leading role.

## List Comprehensions in PureScript
