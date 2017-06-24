# A collection of Either examples compared to imperative code

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 5** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where I cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 4 Part 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P2)

Welcome to Tutorial 5 in the series **Make the leap from Javascript to PureScript**.  I hope you've enjoyed the learnings thus far.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) to learn how to install and run PureScript. I borrowed (with permission) this series outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption is that you have watched his [video](https://egghead.io/lessons/javascript-composable-error-handling-with-either) before tackling the equivalent PureScript abstraction featured in this tutorial.  And for this particular tutorial, you should also review his [transcript](https://egghead.io/lessons/javascript-a-collection-of-either-examples-compared-to-imperative-code#/tab-transcript), which has the imperative and FP code examples in Javascript.  Brian covers the featured concepts extremely well, and it's better that you understand its implementation in the comfort of JavaScript.

If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05).  Finally, If you are enjoying this series then please help me to tell others by recommending this article and/or favoring it on social media


## PureScript code organization

Each of the examples below shows the FP example in JavaScript, followed by its port to PureScript.
In my [Github repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05), you will find each code snippet in a separate PureScript file; importing `ExampleX.purs` and calling it from `Main.purs`.  All my utility functions, including `chain` and `fromNullable`, and their corresponding FFI are in the `Data` folder.  Example 5 requires reading a JSON file, so I have created `example.json` and put it in the folder `./src/resources`.

A few of the examples simulate receiving JSON objects and values over the wire.  If I were doing this in production, I would probably use [purescript-argonaut](https://github.com/purescript-contrib/purescript-argonaut-core/blob/master/README.md) to parse the JSON and transform the objects and values into PureScript Records and basic types respectively.  But I want to keep it simple, so I decided to access the JavaScript objects and their name/value pairs using the FFI.  Furthermore, I treat them as `Foreign` types until I print them to the console.


### fromNullable and fromEmptyString

When handling `Foreign` types returned from a Javascript function or from JSON coming over the wire, there is always the possibility that they may be `null` or `undefined`.   But in PureScript there are no `null` or `undefined` values, so we typically represent this concept by the value `Nothing` from the [`Maybe`](https://pursuit.purescript.org/packages/purescript-maybe/3.0.0/docs/Data.Maybe#t:Maybe) type. Think of `Nothing` as something like a type-safe `null` and, for now, we'll save further details on the `Maybe` type for a later tutorial.

To match Brian's code examples, I created `fromNullable` to check whether a `Foreign` type is `null` or `undefined`, returning `Either Error Foreign`.  Similarly, `fromString` returns `Either Error String`, depending on whether a string is empty.  I am always looking for opportunities to DRY (Don't Repeat Yourself) out my code and found `fromNullable` and `fromString` to be very similar.  So I abstracted the repetition into a separate function, `toEither`.  This method is another example of the benefits of PureScript's support for polymorphism.  Notice how I was able to make `Right x` a polymorphic type so that it works for both `Foreign`, `String` and other types.

```haskell
toEither :: forall a. Boolean -> String -> a -> Either Error a
toEither predicate errorMsg value =
  if predicate
    then Left $ error errorMsg
    else Right value

fromEmptyString :: String -> Either Error String
fromEmptyString value =
  toEither (value == "") "empty string" value

fromNullable :: Foreign -> Either Error Foreign
fromNullable value =
  toEither (isNull value || isUndefined value) "null or undefined" value
```


## Example 1 - Point-Free style (tacit programming)

In PureScript and other FP languages, you'll frequently find that, while a type declaration of a function states that it accepts arguments (or points), the actual arguments are missing in the implementation.  We call this paradigm, point-free or tacit style programming, and it helps 'sometimes' to give a precise definition of the function.  I said 'sometimes', because point-free can also obscure the meaning of a function; particularly when an argument name helps in understanding a function's implementation.  The PureScript example below has been written in a point-free style.

### Javascript
```javascript
const openSite = () =>
    fromNullable(current_user)
    .fold(showLogin, renderPage)
```
### PureScript
```haskell
openSite :: Foreign -> String
openSite =
  fromNullable >>>
  either (\_ -> "showLogin") \_ -> "renderPage"
```

I chose point-free to illustrate this paradigm and to take advantage of function composition. That is, `openSite = fromNullable >>> . . .` instead of `openSite currentUser = (fromNullable currentUser) # . . .`

But it is debatable whether it remains clear that it takes a current user. So, given that your mileage will vary, always proceed with caution when deciding whether to use point-free style.

## Example 2
### Javascript
```javascript
const getPrefs = user =>
    (user.premium ? Right(user) : Left('not premium'))
    .map(u => u.preferences)
    .fold(() => defaultPrefs, prefs => loadPrefs(prefs))
```
### PureScript
```haskell
getPrefs :: Foreign -> String
getPrefs user =
  toEither (getPremium user) "not premium" user #
  map getPreferences >>>
  either (\_ -> defaultPrefs) \prefs -> "loadPrefs " <> prefs
```  

## Example 3 - Say goodbye to chain
### JavaScript
```javascript
const streetName = user =>
    fromNullable(user.address)
    .chain(a => fromNullable(a.street))
    .map(s => s.name)
    .fold(e => 'no street', n => n)
```
### PureScript
```haskell
streetName :: Foreign -> String
streetName user =
  (fromNullable $ getAddress user) >>=
  (\address -> fromNullable $ getStreet address) >>=
  (\street -> fromNullable $ getStreetName street) >>>
  map (\name -> unsafeFromForeign name :: String) #
  either (\_ -> "no street") id
```  

Wait! What happened to `chain`?  Well, I have a secret that I've been keeping since the last tutorial - you can replace `chain` with `bind` (`>>=`)!  I know, shocking isn't it.  Perhaps I should have come clean earlier, but I felt it was better to stick with `chain` from Brian's tutorials.  So why and when can we replace `chain` with `bind` you ask?  Let's look at their type declarations to see if that helps to illuminate things:

```haskell
chain :: forall a b e. (a -> Either e b) -> Either e a -> Either e b
bind  :: forall a b.   m a               -> (a -> m b) -> m b
```

Nope, not really.  Hold on a minute - let's try looking at their implementations.  First `chain`:
```haskell
chain :: forall a b e. (a -> Either e b) ->  Either e a -> Either e b
chain f = either (\e -> Left e) (\a -> f a)
```

Then, let's look at the `bind` class instance for `Either` from [Either.purs](https://github.com/purescript/purescript-either/blob/master/src/Data/Either.purs)

```haskell
-- | The `Bind` instance allows sequencing of `Either` values and functions that
-- | return an `Either` by using the `>>=` operator:
-- |
-- | ``` purescript
-- | Left x >>= f = Left x
-- | Right x >>= f = f x
-- | ```
instance bindEither :: Bind (Either e) where
  bind = either (\e _ -> Left e) (\a f -> f a)
```

Interesting, so `bind` is quite similar to my implementation of `chain`, but with the first two arguments flipped!  Why does this work?  Well, if `bind` sees that the first argument is `Left e` then, like `chain`, it ignores the the second function argument `(\a f -> f a)`, and returns the first argument, `Left e`. But if the first argument is `Right a` then the second function argument is applied. Finally, because `f a -> Either e b`, then `Either e b` will be returned.  

The next question is 'when can I substitute `chain` with `bind`?  Well, for all intents and purposes, they’re interchangeable! Consequently, you won't find a class instance of `chain` in `Either.purs`.  Take a quick look at Example 6, where I've provided two versions of `parseDbUrl` - one using `chain` and the other using `bind`.  That example should help you to go back and refactor any functions using `chain` to `bind`. So . . . say goodbye to `chain` and long live `bind`!


## Example 4 - Anonymous Function Arguments
### JavaScript
```javascript
const concatUniq = (x, ys) =>
    fromNullable(ys.filter(y => y === x)[0])
    .fold(() => ys.concat(x), y => ys)
```
### PureScript
```haskell
concatUniq :: String -> String -> String
concatUniq x ys =
  filter (_ == x) ys #
  fromEmptyString #
  either (\_ -> ys <> x) \_ -> ys
```

This tip is straightforward and very useful in practice.  In the PureScript example above, notice the expression `filter (_ == x) ys`.  You may be wondering why I didn't write it as `filter (\y -> y == x) ys`.  Well, because I'm using an anonymous function argument `_`, represented in the predicate portion of the filter function.  Think of `_` as a little syntax sugar that helps to shorten your code.  You'll be pleased to know that anonymous function arguments work for Records and other types of expressions, as well.  You can learn everything you need to know about them in this [blog post](https://github.com/paf31/24-days-of-purescript-2016/blob/master/7.markdown), which is part of the series '24-days-of-purescript-2016'.  


## Example 5 - `let` vs. `where` keywords

Before discussing the `let` and `where` keywords, let me mention that this code snippet makes good use of native side effects.  That topic was well covered in [Part 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P2) of Tutorial 4, so if you're still shaky on File IO and exception handling then go back and have a look.  Now onto the use of  `where` vs. `let` keywords in the duel `wrapExample` snippets.  
### JavaScript
```javascript
const readFile = x => tryCatch(() => fs.readFileSync(x))

const wrapExample = example =>
    fromNullable(example.previewPath)
    .chain(readFile)
    .fold(() => example,
          preview => Object.assign({}, example, preview))
```
### PureScript
```haskell
wrapExample :: forall eff. Foreign -> Eff (fs :: FS, exception :: EXCEPTION | eff) Foreign
wrapExample example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  either (\_ -> pure example) wrapExample'
  where
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      either Left parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure

wrapExample_ :: forall eff. Foreign -> Eff (fs :: FS, exception :: EXCEPTION | eff) Foreign
wrapExample_ example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  let
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      either Left parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure
  in
    either (\_ -> pure example) wrapExample'
```

We have seen the `where` keyword many times before.  It is usually at the top of a module, for the purpose of delineating the block of code represented by the module name.  But, so far, I haven't used it inside a function.  The purpose is the same - introduce a new block of code, indenting that code so that the compiler understands that `where` is bound to the syntactic construct (i.e., the new block of code).  In the example, you can see that `where` is forever linked to the code that defines `wrapExample' `.

Now, take a look at `let`.  At first blush, the purpose of `where` and `let` appear to be identical, and this is roughly correct.  But there is a subtle difference!   `let . . . in . . .` is also an expression, and therefore can be written wherever expressions are allowed.  The code snippet best explains this difference. I used `let . . . in . . .` as an expression by inserting it between the `map` and `either ` functions.  I could have gone even further, with the following:

```haskell
map (\path -> unsafeFromForeign path :: String) >>>
either (\_ -> pure example)
  let wrapExample' pathFile = . . .
  in wrapExample'
```

But, then it becomes a matter of readability.  

For more information on `let` vs. `where`, check out [Let vs. Where](https://wiki.haskell.org/Let_vs._Where) from wiki.haskell.org.  Oh, and you are going to find that the syntax of Haskell is surprisingly similar to PureScript!  I've heard a few PureScripters commenting that they were able to pick up Haskell much more quickly, thanks to having learned PureScript first.  Likewise, I began learning Haskell first and found I was able to pick up PureScript more rapidly.

## Example 6 - Regular expression validators and partial functions

First, before discussing regular expressions in PureScript, my reason for creating the dual code snippets below, `parseDbUrl and parseDbUrl_`, is to demonstrate how to port functions that use `chain`, to use `bind` instead. This code snippet will be the last time you will see chain in my tutorials. And to learn why, then please review the discussion in Example 2.
### JavaScript
```javascript
const parseDbUrl = cfg =>
    tryCatch(() => JSON.parse(cfg))
    .chain(c => fromNullable(c.url))
    .fold(e => null,
          u => u.match(/postgres:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/))
```
### PureScript
```haskell
dBUrlRegex :: Partial => Regex
dBUrlRegex =
  unsafePartial
    case regex "^postgres:\\/\\/([a-z]+):([a-z]+)@([a-z]+)\\/([a-z]+)$" noFlags of
      Right r -> r

matchUrl :: Regex -> String -> Either Error (Array (Maybe String))
matchUrl r url =
  case match r url of
    Nothing -> Left $ error "unmatched url"
    Just x -> Right x

parseDbUrl_ :: Partial => String -> Array (Maybe String)
parseDbUrl_ =
  parseValue >>>
  chain (\config -> fromNullable $ getDbUrl config) >>>
  map (\url -> unsafeFromForeign url :: String) >>>
  chain (matchUrl dBUrlRegex) >>>
  either (\_ -> singleton Nothing) id

parseDbUrl :: Partial => String -> Array (Maybe String)
parseDbUrl s =
  (parseValue s) >>=
  (\config -> fromNullable $ getDbUrl config) >>>
  map (\url -> unsafeFromForeign url :: String) >>=
  (\r -> matchUrl dBUrlRegex r) #
  either (\_ -> singleton Nothing) id
```

Like JavaScript, PureScript supports the use of regular expressions very well - by wrapping JavaScript's very own `RegExp` object!  The types and functions are part of the `purescript-strings` library, located in the module `[Data.String.Regex](https://pursuit.purescript.org/packages/purescript-strings/3.2.1/docs/Data.String.Regex#t:Regex)`.   First up is the `Regex` object.

There's some new pieces of syntax in the `DbUrlRegex` function, namely  `Partial` and `unsafePartial`. In this instance, they allow us to treat a non-exhaustive case expression as a regular case expression (unsafely).  So why did I decide  `unsafePartial`? I tested the regular expression `"^postgres:\\/\\/([a-z]+):([a-z]+)@([a-z]+)\\/([a-z]+)$"` and I know it works for the sole purpose of demonstration in this tutorial!  So no need to bother returning and dealing with an `Either Error Regex`.  You can also take advantage of `unsafePartial` to return partial functions; again unsafely.  And, as a consequence of `DbUrlRegex`, that is exactly what I am doing in `parseDbUrl`.

You’ll often hear from functional programmers the phrase, ‘Let the types be your guide’. So, with that mantra in mind, `DbUrlRegex` is a partial function, so I declare that it belongs to the `Partial` class (i.e., `dbUrlRegex :: Partial => Regex`).  This fact propagates all the way back to `main`.  I declare that `parseDbUrl` returns a partial function and, consequently, in the `main` code snippet below, I use the `unsafeFromPartial` function to log the result to the console.

One final item - `parseDbUrl` returns `Array (Maybe String)`, and so you're probably wondering about the `Maybe` constructor.  As I mentioned in the `fromNullable` and `fromEmptyString` section, we'll cover that abstraction in a future tutorial.

## Main program
```haskell
defaultConfig :: String
defaultConfig = "{ \"url\": \"postgres:\\/\\/username:password@localhost/mydb\"}\n"

main :: forall e. Eff (fs :: FS, exception :: EXCEPTION, console :: CONSOLE | e) Unit
main = do
  log "A collection of Either examples"

  log "Example 1"
  log $ openSite getCurrentUser

  log "Example 2"
  log $ getPrefs getCurrentUser

  log "Example 3"
  log $ streetName getCurrentUser

  log "Example 4"
  log $ concatUniq "x" "ys"
  log $ concatUniq "y" "y"

  log "Example 5"
  log "using where keyword in wrapExample"
  example <- wrapExample getCurrentExample
  log $ unsafeFromForeign example :: String

  log "Example 6"
  log "Using bind to help parse the database URL"
  logShow $ unsafePartial $ parseDbUrl defaultConfig

  log "Game Over"
```  

That's all for now. In the next Tutorial we're going to learn a new algebraic structure, called Semigroups.  If you are enjoying this series then please help me to tell others by recommending this article and/or favoring it on social media.  Thank you and till next time!

## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
