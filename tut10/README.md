# Unbox types with foldMap

![series banner](../resources/glitched-abstract.jpg)

> *This is* **Tutorial10** *in the series* **Make the leap from JavaScript to PureScript**. Be sure
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-month. So come back often, there is a lot more to come!*

> [Index](https://github.com/adkelley/javascript-to-purescript/tree/master/index.md) | [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 9](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09) | [Tutorial 11 >](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11) [>> Tutorial 25](https://github.com/adkelley/javascript-to-purescript/tree/master/tut25)

Welcome to Tutorial 10 in the series **Make the leap from Javascript to PureScript** and I hope you're enjoying it thus far.  We're going to continue our brief but spectacular journey exploring monoids.  But first, good news!  If you have been following Brian's [tutorials](https://egghead.io/lessons/javascript-unboxing-things-with-foldable) (and you should be), we are ahead on the topics that we need to cover.  In our case, it was more appropriate to introduce `foldMap` in [Tutorial 9](https://github.com/adkelley/javascript-to-purescript/tut09).  So we will take this opportunity of being ahead of the material to look at `foldMap` a little more while adding a few more monoids to our toolbox. I will also touch a little bit on generic programming, which is something you'll want to take advantage of going forward.

Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) the outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-unboxing-things-with-foldable) before tackling the equivalent PureScript abstraction featured in this tutorial.  Brian covers the featured concepts extremely well, and it's better you understand its implementation in the comfort of JavaScript.

You will find the markdown and all code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a [pull request](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10).  Finally, If you are enjoying this series, then please help me to tell others by recommending this article and favoring it on social media.  My Twitter handle is [@adkelley](https://twitter.com/adkelley).

##  One final look at foldMap
In the [last tutorial](https://github.com/adkelley/javascript-to-purescript/tut09/) we learned that `foldMap` for monoids essentially combines `foldr`, `mempty` and `map` into one function. For example, in JavaScript, we saw how Brian was able to take

```javascript
const res = List.of(1, 2, 3)
            .map(Sum)
            .fold(Sum.empty())
```
and shorten it to
```javascript
const res = List.of(1, 2, 3)
            .foldMap(Sum.empty())
```

Why?  Well given that the pattern of mapping and 'right folding' monoids is so prevalent, our 'FP overlords' were benevolent and kind to combine them into one expression for us.  Well, maybe not, but let's see how by taking a look at the type declarations.  First up is the `map` function, which has the following type declaration.

```haskell
class Functor f where
  map :: ∀ a b. (a -> b) -> f a -> f b
```
We haven't covered `Functor` yet so, for now, just think of it as something that can be mapped over, like an array.  Here, `(a -> b)` is lifted over `f` to transform each value of type `a` to a value of type `b`, and finally wrapping it back again in `f`.  Using our canonical `Additive` monoid, I've created the following code examples.  And to keep the type declarations to one line, I made a type alias which substitutes `Additive Int` for `Sum`.

```haskell
type Sum    = Additive Int

map    ::    (a   -> b )   -> f    a   -> f    b
map'   ::    (Int -> Sum)  -> List Int -> List Sum

map' Sum (1 : 2 : 3 : Nil) -- (Sum 1 : Sum 2 : Sum 3 : Nil)
```

So far so good.  Now, let’s take a look at 'right fold' (i.e., `foldr`). Data structures that belong to the `Foldable` class, such as an array or list, are those that you can fold into a summary value.  The first argument, `(a -> b -> b)` is a function from `(a -> b)` that returns a `b`.  Keeping with the `Additive` monoid as our example, we'll use `append` for this function.  To `right fold` on `f`, we also need our identity value `b` to append to the last transformed element in `f`. We'll use `mempty` for this second argument, which is `Additive 0`.

```haskell
type Sum = Additive Int

class Foldable f. where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b

foldr' :: (Sum -> Sum -> Sum) -> Sum -> List Sum -> Sum

let id = mempty :: Additive Int
let xs = (Additive 1 : Additive 2 : Additive 3 : Nil)
foldr' append id xs -- (Additive 6)
```

Finally, we're ready to put all the pieces together, showing that `foldMap` for monoids is effectively a combination of the `map`, `mempty`, and `foldr` expressions.  Notice that, unlike `foldr`, the first argument `(a -> m)` of `foldMap` is a type constructor that must map to a monoid.  In our case, its `Additive` and the identity value `mempty` is implicit from the monoid.
```haskell
type Sum = Additive Int

class Foldable f where
  foldMap ::  forall a m
           .  Monoid m
          => (a   -> m)    -> f    a   -> m
foldMap'  :: (Int -> Sum)  -> List Int -> Sum

main =
  let mapSum = map Additive (1 : 2 : 3 : Nil)
  let foldSum = foldr (<>) mempty
  logShow $ foldSum mapSum == foldMap' Additive (1 : 2 : 3 : Nil) -- true
```

## More monoids, please
It's time to add a few more monoids to the list we created from the [last tutorial](file:///Users/alexkelley/Dropbox/cs/purescript/javascript-to-purescript/tut09/README.md), starting with `Dual`: 

```haskell
Dual x <> Dual y == Dual (y <> x)
mempty :: Dual _ == Dual mempty
```

With the ability to flip its arguments, the `Dual` monoid is interesting, because it shows that there can be several valid instances of the `Monoid` class for a given datatype.  In the example below, we'll use the instance `(Monoid a) => Monoid (Dual a)` to demonstrate how `Dual` can flip monoids `a`, contained within a foldable structure that is also a monoid.

```haskell
switchArgs :: ∀ f m. Foldable f ⇒ Monoid m ⇒ f m → Dual m
switchArgs = foldMap Dual

main = do
  logShow $ switchArgs ["Alex", ", ", "Kelley"] -- (Dual "Kelley, Alex")
  logShow $ switchArgs ("Alex" : ", " : "Kelley" : Nil) : Nil -- ((Dual "Kelley, "Alex") : Nil)
```
In the last tutorial, you may recall I mentioned that strings are monoids, and so are arrays and lists. We take advantage of the instance `(Monoid a)  => Monoid(Dual a)` to take an array of strings `["Alex", ", ", "Kelley"]` and reformat it to `Dual("Kelley,  Alex")`. Notice in the first example, I used an array to store my strings, but in the second example, I used a list. How is that even possible? Don't we have to explicitly declare our data structures, such as `Array` or `List` in our type declaration? Well, read on to solve this mystery. You're in for a nice surprise!

### Generic programming
Let's take a brief detour to talk about generic programming.  Again, notice that the type declaration for `switchArgs` has no explicit declaration of our datatypes.  The advantage of this approach is that `switchArgs` is a 'generic' function.  Meaning that, instead of writing multiple `switchArgs` methods to support alternative data structures, I needed only to write one generic function that has abstracted them out.  Instead, we define the class of types that we will accept, like `Foldable` and `Monoid`, and let the compiler take care of ensuring that the caller of our function sends in the proper arguments.  I encourage you to use this paradigm whenever possible because it'll not only save you a lot of keystrokes and make your functions more general purpose.

### Back to our regularly scheduled programming
Let’s look at our next monoid, `Tuple`.  Yes, I know we covered this one in the previous tutorial, but there is one other point I would like to touch on.  That is, "what if your tuple holds two values of different types and you want to map and fold them?".  No problem,  just compose `fst` or `snd` with your target monoid and behold:
```haskell
 log "\nWorking with Tuples, then use 'fst' or 'snd'"
 logShow $ foldMap (Additive <<< snd) [Tuple "brian" 1, Tuple "sarah" 2] -- (Additive 3)
 logShow $ foldMap (Dual <<< fst) [Tuple "Brian" 1, Tuple " and " 2, Tuple "Sarah" 2] -- (Dual "Sarah and Brian")
```

Next up is `Endo`, which is short for endomorphism.  I know what you’re going to say - "Here comes Mr. Smarty-Pants again with another one of his fancy terms from category theory.  All kidding aside, like all the other mathematical terms I introduced thus far, this one is just as easy to understand once you get over the name.  The word "endo" means "combining form," and "morphism" means "mapping between objects".  In our case, it just means that functions `(a -> a)` that take an element of type `a` and return an `a` can be composed together and that this composition is associative. 
```haskell
((a -> a) <<< (a -> a)) <<< (a -> a)  == (a -> b) <<< ((a -> a) <<< (a -> a))
```
So, do we have ourselves a monoid?  You bet because the append operation for `Endo` is function composition `(<<<)` and the identity value `mempty`, the identity function `id`.  It applies the function `(a -> a)`, leaving the value unchanged:
```haskell
Endo f <> Endo g == Endo (f <<< g)
mempty :: Endo _ == Endo id
```
Here's an example:
```haskell
let h = unwrap $ foldMap Endo [(+) 1, (*) 2, negate]
logShow $ h 5 -- -9
```
Note that we unwrap Endo to be able to log the result to the console.  Otherwise, it's still a type constructor.
```haskell
> :t foldMap Endo [(+) 1, (*) 2, negate]
Endo Int

> :t unwrap $ foldMap Endo [(+) 1, (*) 2, negate]
Int -> Int
```

And lastly, there's `Last`, which should be no surprise is the opposite of `First`.  So instead of returning the first non-nothing value in a foldable data structure, `Last` will return the last non-nothing value.  Nuff said!
```haskell
foldMap Last [(Just 1), Nothing, (Just 2)] -- (Just 2)
```

## Abelian monoids
"Hello, it's me, Mr. Smarty-Pants again.  I thought I would introduce one final monoid from category theory, called the Abelian Monoid."  [Smarty Pants Voice](https://youtu.be/BSwqbhjLyrY?t=48s) - "An Abelian Monoid is a monoid that is also commutative; like addition and multiplication, but not lists or strings, for which order is significant." For example:
```
a * b * c == c * b * a  -- communitive
"a" <> "b" <> "c" ≠ "c" <> "b" <> "a" -- not communitive
```
As Steven Syrek mentions in his [blog post](https://medium.com/@sjsyrek/five-minutes-to-monoid-fe6f364d0bba) - "You can also just say commutative monoid or, if you prefer, not talk about them at all. But do spread the word about monoids." I couldn't agree with him more.  So post the following in your favorite FP subreddit: "TIL Abelian Monoids are monoids that are not only associative, but they're also communitive!"  And thou shalt receive high praise from thine FP overlords 😉.

## Bonus - You should write some tests!
We'll be covering testing in PureScript in the next tutorial, so here's a [preview](https://github.com/adkelley/javascript-to-purescript/tree/master/tut10/test/Main.purs) for those who would like to get a head start.

## Summary
In this tutorial, we ended our brief but spectacular journey exploring the power of monoids. We learned that the `foldMap` expression for folding monoids, is essentially a combination of `map`, `foldr`, and `mempty`.  We also added a few more monoids to our toolbox, with the observation that we can use the same monoid in several different instances (e.g., `Dual`).  We saw the newtype `(a → a)` is represented by the monoid `Endo`, whose append operation is function composition and the identity value `id`.  And we ended with the `abelian monoid`, which is simply a monoid that is also communitive (e.g., `Multiplicative`).

Once again, whether or not you’re finding these tutorials helpful in making the leap from JavaScript to PureScript then give me clap, drop me a comment, or post a tweet. My twitter handle is @adkelley. I believe any feedback is good feedback and helpful toward making these tutorials better in the future. Till next time.


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut09) **Tutorials** [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut11)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
