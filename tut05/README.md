# A collection of Either examples compared to imperative code

![series banner](../resources/glitched-abstract.jpg)

> *Note: This is* **Tutorial 4 - Part 2** *in the series* **Make the leap from JavaScript to PureScript** *. Be sure*
> *to read the series introduction where we cover the goals & outline, and the installation,*
> *compilation, & running of PureScript. I will be publishing a new tutorial approximately*
> *once-per-week. So come back often, there is a lot more to come!*

> [<< Introduction](https://github.com/adkelley/javascript-to-purescript) [< Tutorial 4 Part 2](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04P2)

Welcome to Tutorial 5 in the series **Make the leap from Javascript to PureScript**.  Be sure to read the series [Introduction](https://github.com/adkelley/javascript-to-purescript) where you'll find the Javascript reference for learning FP abstractions, but also how to install and run PureScript. I borrowed (with permission) the series outline and javascript code samples from the egghead.io course [Professor Frisby Introduces Composable Functional JavaScript](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) by
[Brian Lonsdorf](https://github.com/DrBoolean) - thank you, Brian! A fundamental assumption of each tutorial is that you've watched his [video](https://egghead.io/lessons/javascript-composable-error-handling-with-either) before tackling the equivalent PureScript abstraction featured in this tutorial.  For this particular tutorial, you should also review his [transcript](https://egghead.io/lessons/javascript-a-collection-of-either-examples-compared-to-imperative-code#/tab-transcript) which has the imperative and FP code examples in Javascript.  Brian covers the featured concepts extremely well, and I feel it's better that you understand its implementation in the comfort of JavaScript. Finally, if you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut05).


## PureScript code organization

To help keep the examples organized, I placed each code snippet from Brian's tutorial in a separate PureScript file.  Then ExampleX.purs (Examples 1-6) are imported and called by `Main.purs`.  You will find my utility functions, such as `chain` and `fromNullable`, along with their corresponding FFI in the `Data` folder.  Note I've refactored `chain` to be point-free for these examples, so it is worth looking at if you're interested in this approach (for further discussion, see Example 2).  Finally, Example 5 calls for reading a JSON file, so I've created `example.json` and put it in the folder `./src/resources`.

## Utility functions

A few of the examples simulate receiving JSON objects and values over the wire.  So, throughout these examples, we are going handle multiple `Foreign` objects, along with the possibility that these objects may be null or undefined and strings objects may be empty.  

Now in PureScript, unless you're handling `Foreign` objects, there are no `null` or  `undefined` values.  Instead, we typically represent it by the value `Nothing` from the `Maybe` constructor.  Nothing indicates that a returned value does not contain a value, but we'll save further details on the `Maybe` abstraction for a later tutorial.  

### fromNullable and fromEmptyString

A few of the examples simulate receiving JSON objects and values over the wire.  If I were doing this in production, I would likely use [purescript-argonaut](https://github.com/purescript-contrib/purescript-argonaut-core/blob/master/README.md) to parse the JSON and transform the objects into a PureScript Record type.  But I want to keep it simple, so I access the objects and their name/value pairs using the FFI.  Throughout this tutorial, we are going handle multiple `Foreign` objects, along with the possibility that these objects may be null or undefined and string objects may be empty.  

Now in PureScript, unless you're handling `Foreign` objects returned from Javascript or JSON over the wire, there are no `null` or  `undefined` values.  Instead, we typically represent it by the value `Nothing` from the `Maybe` constructor.  `Nothing` indicates that a returned value does not contain a value.  I know this may be confusing, but we'll have to save further details on the `Maybe` abstraction for a later tutorial.  

I've created the function `fromNullable` (see below) that checks whether a `Foreign` object or value is `null` or `undefined` and returns `Either Error Foreign`.  Similarly, `fromString` returns `Either Error Foreign`, depending on whether a string is empty (i.e., string === "").  I'm always looking for opportunities to DRY (Don't Repeat Yourself) my code,  so I abstracted the repeated condition checking from both functions into a function `fromNullable'`.

```haskell
fromNullable' :: forall a. Boolean -> String -> a -> Either Error a
fromNullable' cond errorMsg value =
  if cond
    then Left $ error errorMsg
    else Right value

fromEmptyString :: String -> Either Error String
fromEmptyString value =
  fromNullable' (value == "") "empty string" value

fromNullable :: Foreign -> Either Error Foreign
fromNullable value =
  fromNullable' (isNull value || isUndefined value) "null or undefined" value
```


## Example 1 - Incoming JSON over the wire
```javascript
const openSite = () =>
    fromNullable(current_user)
    .fold(showLogin, renderPage)
```

```haskell
openSite :: Foreign -> String
openSite =
  fromNullable >>>
  chain (\user -> fromNullable $ getName user) >>>
  map (\name -> unsafeFromForeign name :: String) >>>
  either
    (\_ -> "showLogin()")
    \name -> "renderPage(" <> name <> ")"
```

## Example 2 - Point Free style
```javascript
const getPrefs = user =>
    (user.premium ? Right(user) : Left('not premium'))
    .map(u => u.preferences)
    .fold(() => defaultPrefs, prefs => loadPrefs(prefs))
```

```haskell
isPremium :: Foreign -> Either String Foreign
isPremium user =
  if (getPremium user)
    then Right user
    else Left "not premium"

getPrefs :: Foreign -> String
getPrefs =
  isPremium >>>
  map getPreferences >>>
  either (\_ -> defaultPrefs) \prefs -> "loadPrefs(" <> prefs <> ")"
```  

## Example 3 - Substituting chain with bind

```javascript
const streetName = user =>
    fromNullable(user.address)
    .chain(a => fromNullable(a.street))
    .map(s => s.name)
    .fold(e => 'no street', n => n)
```

```haskell
-- Look ma - no chains!
streetName :: Foreign -> String
streetName user =
  (fromNullable $ getAddress user) >>=
  (\address -> fromNullable $ getStreet address) >>=
  (\street -> fromNullable $ getStreetName street) >>>
  map (\name -> unsafeFromForeign name :: String) #
  either (\_ -> "no street") id
```  

## Example 4 - Anonymous Function Arguments

```javascript
const concatUniq = (x, ys) =>
    fromNullable(ys.filter(y => y === x)[0])
    .fold(() => ys.concat(x), y => ys)
```

```haskell
concatUniq :: String -> String -> String
concatUniq x ys =
  filter (_ == x) ys #
  fromEmptyString #
  either (\_ -> ys <> x) \_ -> ys
```

## Example 5 - Native Side Effects
```javascript
const readFile = x => tryCatch(() => fs.readFileSync(x))

const wrapExample = example =>
    fromNullable(example.previewPath)
    .chain(readFile)
    .fold(() => example,
          preview => Object.assign({}, example, preview))
```

```haskell
wrapExample :: forall eff. Foreign -> Eff (fs :: FS, exception :: EXCEPTION | eff) Foreign
wrapExample example =
  fromNullable (getPreviewPath example) #
  map (\path -> unsafeFromForeign path :: String) >>>
  either (\_ -> pure example) wrapExample'
  where
    wrapExample' pathToFile =
      (try $ readTextFile UTF8 pathToFile) >>=
      chain parseValue >>>
      either (\_ -> example) (assignObject2 example) >>>
      pure
```

## Example 6 - Chain is just Either under the hood
```javascript
const parseDbUrl = cfg =>
    tryCatch(() => JSON.parse(cfg))
    .chain(c => fromNullable(c.url))
    .fold(e => null,
          u => u.match(/postgres:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/))
```

```haskell
dBUrlRegex :: Regex
dBUrlRegex =
  unsafePartial
    case regex "^postgres:\\/\\/([a-z]+):([a-z]+)@([a-z]+)\\/([a-z]+)$" noFlags of
      Right r -> r

matchUrl :: Regex -> String -> Either Error (Array (Maybe String))
matchUrl r url =
  case match r url of
    Nothing -> Left $ error "unmatched url"
    Just x -> Right x

parseDbUrl :: String -> Array (Maybe String)
parseDbUrl =
  parseValue >>>
  either Left (\config -> fromNullable $ getDbUrl config) >>>
  map (\url -> unsafeFromForeign url :: String) >>>
  either Left (matchUrl dBUrlRegex) >>>
  either (\_ -> singleton Nothing) id
```

## Main program
```haskell
defaultConfig :: String
defaultConfig = "{ \"url\": \"postgres:\\/\\/username:password@localhost/myjavascriptdb\"}\n"

main :: forall e. Eff (fs :: FS, exception :: EXCEPTION, console :: CONSOLE | e) Unit
main = do
  log "A collection of Either examples"

  log "Example 1"
  log $ openSite getCurrentUser
  log $ openSite returnNull

  log "Example 2"
  log $ getPrefs getCurrentUser

  log "Example 3"
  log $ streetName getCurrentUser

  log "Example 4"
  log $ concatUniq "x" "ys"
  log $ concatUniq "y" "y"

  log "Example 5"
  example <- wrapExample getCurrentExample
  log $ unsafeFromForeign example :: String

  log "Example 6"
  logShow $ parseDbUrl defaultConfig

  log "Game Over"
```  


## Navigation
[<--](https://github.com/adkelley/javascript-to-purescript/tree/master/tut04) Tutorials [-->](https://github.com/adkelley/javascript-to-purescript/tree/master/tut06)

You may find that the README for the next tutorial is under construction. But if you're an eager beaver and would like to look ahead, then all the of code samples from Brian's [videos](https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript) have been ported to PureScript already. But I may amend them as I write the accompanying tutorial markdown.  
