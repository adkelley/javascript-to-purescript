# Build a data flow for a real-world app

![series banner](../resources/glitched-abstract.jpg)

> **Note: This is** **Tutorial 27** **in the series** **Make the leap from JavaScript to PureScript**. Be sure
> **to read the series introduction where we cover the goals & outline, and the installation,**
> **compilation, & running of PureScript. I'll be publishing a new tutorial approximately**
> **once-per-month. So come back often, there's a lot more to come!**
> 
> [Index](https:github.com/adkelley/javascript-to-purescript/tree/master/md) | [<< Introduction](https:github.com/adkelley/javascript-to-purescript) [< Tutorial 26](https:github.com/adkelley/javascript-to-purescript/tree/master/tut26)

In the [last Tutorial](https://github.com/adkelley/javascript-to-purescript/tree/master/tut26/), we finished all of the basic concepts of functional programming.  Now, we'll use what we learned to develop an application that finds common ground between two music artists, using the [Spotify API](https://developer.spotify.com/console/).   In this first of our final three tutorials, we'll determine the necessary HTTP endpoints from the Spotify API.  Once we have our endpoints, we'll sketch a high-level dataflow diagram.  Then, by following our diagram, we'll begin coding this data flow in PureScript.

I borrowed this series outline, and the JavaScript code samples with permission from the egghead.io course 'Professor Frisby Introduces Composable Functional JavaScript' by
Brian Lonsdorf — thank you, Brian! A fundamental assumption is that you've watched his [video](https://egghead.io/lessons/javascript-real-world-example-pt1) on the topic before tackling the equivalent PureScript abstraction. Brian covers the featured concepts exceptionally well, and I feel it's better that you understand its implementation in the comfort of JavaScript. **Note** that the Spotify API has [evolved](https://developer.spotify.com/community/news/2017/01/27/removing-unauthenticated-calls-to-the-web-api/) since Brian published his tutorial.  In particular, they have removed unauthenticated calls to all of their API endpoints. Consequently, to make this application work, you'll need a Spotify account to obtain an API security access token.

You'll find the text and code examples for this tutorial on [Github](https://github.com/adkelley/javascript-to-purescript/tree/master/tut27/).  If you read something that you feel could be explained better, or a code example that needs refactoring, then please let me know via a comment or send me a pull request.  Also, if you like what you see, then please give it a star to help me publicize these tutorials.


## What we're building

We're going to build an application that finds common music artists shared between two or more artists by querying the [Spotify API](https://developer.spotify.com/console/). For example, if a user inputs The Beatles and The Rolling Stones, then our application returns an array of artists that the Spotify algorithm determines they have in common.  The code for the completed application is in [Tutorial 29](https://github.com/adkelley/javascript-to-purescript/tree/master/tut29). You can run this final implementation by typing the following in your terminal:

    # Compiles and produces a single executable 'tuindex.js'
    $ npm run bundle
    # Use node to run it
    $ node index.js Beatles 'Rolling Stones'
    # Returns 34 related artists; 5 artists in common.
    $ (Tuple 34 ["Jimi Hendrix","The Kinks","George Harrison","Chuck Berry","Eric Clapton","John Lennon"])


### Development Roadmap

Here's our development plan:

1.  Start by looking at the [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/) to discover suitable endpoints.
2.  Test these endpoints in the terminal using [Curl](https://www.computerhope.com/unix/curl.htm) and Spotify's [Console](https://developer.spotify.com/console/) to ensure they deliver the metadata we need.
3.  Create a data flow diagram of our application.
4.  Finish coding the user argument capture, while mocking the rest of the data flow in PureScript.

We'll cover each step of our plan in detail in the next four sections.


## Step 1 - Search the Spotify API docs

After a brief tour of Spotify's API documentation, it becomes readily apparent that the [Artists](https://developer.spotify.com/console/artists/) page (see Figure 1 [left panel]) has the metadata we need for our application. In particular, there's an endpoint `/v1/artists/{id}/related-artists` that, given an artist's unique `id`, gets their related artists. So how do we obtain this `id`? Well, there's also the [Search for an Item](https://developer.spotify.com/console/get-search-item/) page, shown in Figure 1 [right panel], hinting we can retrieve an artist `id` by entering a query together with the type of metadata we need.

![img](../resources/tut27_spotify_console.png)

Figure 1 - Spotify API Console

For example, if we want to search for The Beatles, then our API endpoint is `v1/search?q=Beatles&type=artist&limit=1`. To find out if these endpoints are sufficient, let's test them using the tools outlined in the next Section.


## Step 2 - Test the endpoint responses

Armed with our prospective API endpoints, we're ready to begin testing them in the Spotify console shown above.  I found this approach to be the easiest but, naturally, you can also try them out in your terminal using Curl.  For example, if we want to retrieve the artist `id` for The Beatles, then the proper Curl request is along the lines of:

    curl -X "GET" "https://api.spotify.com/v1/search?q=Beatles&type=artist&limit=1" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer YourSecretTokenGoesHere"

Notice that the JSON response contains the artist `id` within the `items` array, nested under `artists`:

    {
      "artists": {
        "href": "https://api.spotify.com/v1/search?query=Beatles&type=artist&offset=0&limit=1",
        "items": [
          {
            ...
            "genres": [
              "british invasion",
              "classic rock",
              "merseybeat",
              "psychedelic rock",
              "rock"
            ],
            "href": "https://api.spotify.com/v1/artists/3WrFJ7ztbogyGnTHbHJFl2",
            "id": "3WrFJ7ztbogyGnTHbHJFl2",
              ...
            ...
          }]
       ...
     }

Satisfied that these two endpoints deliver the metadata we require, we can move onto sketching our data flow before beginning to code in PureScript.


## Step 3 - Sketch the Dataflow Diagram

Recently, I've noticed greater interest by the JavaScript community in using finite states to model the logic in their programs declaratively. They're finding that it's a great way to identify corner cases, and it helps to eliminate mistakes stemming from improper logic. For example, as of this writing, David Khourshid's work on [XState](https://xstate.js.org/docs/) has over 11.5K stars on [Github](https://github.com/davidkpiano/xstate). Be it State Charts, [Behavior Trees](https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control)), or Dataflow Diagrams; they're all useful for describing the behavior of your code to programmers and non-programmers alike.  A Dataflow Diagram illustrates the flow of data explicitly, with objects representing transformations, and the data flow depicted as a line or pipe. They're also simple to draw.  You can model data flow with just four basic symbols, representing a Process, Data Store, External Entity, and a Note.  For example, the Data Flow Diagram directly below utilizes all four basic symbols.

![img](../resources/tut27_process_example.png)

Figure 2 - Process Dataflow (adapted from [Visual Paradigm](https://www.visual-paradigm.com/guide/data-flow-diagram/what-is-data-flow-diagram/))

The leftmost External Entity block represents a user or other outside system that provides **data to** or receives **output from** the system.  Next is the Note, whose arrow designates the path direction of the data, and the label describes the data itself. The Process block receives this input data and transforms it before passing it to the final External Entity.  In this case, we're using a Data Store Entity for storing data to be used at another time. Note that we call External Entities terminators because they designate where the data originates and where it ends.

There's just one basic rule when drawing data flow diagrams - all flow must begin with and end at a Process block. The point here is that an External Entity should not provide data to another External Entity without being processed beforehand. Instead, place a Process block between the two External Entities.  For more information on Data Flow Diagrams, check out the [Visual Paradigm](https://www.visual-paradigm.com/guide/data-flow-diagram/what-is-data-flow-diagram/) website. You can use their tools or pick your favorite drawing program to achieve similar results.  I used [Sketch.app](https://www.sketch.com/) to draw the figures you see in this Section. If you are a Sketch user, then feel free to take my symbols page from the file `flow_diagram.sketch,` located in my [GitHub repository](https://github.com/adkelley/javascript-to-purescript/tree/master/tut27).


### App Dataflow Diagram

Our application is simple, and thus, the Data Flow Diagram, shown in Figure 3, is also simple to understand.  In the next tutorial, we'll add another layer to the diagram to better illustrate our HTTP GET calls to the Spotify API. But it appears that we're looking at approximately three primary functions: Process 1 to extract the artist names from the user command line arguments; Process 2 to take these artist names and obtain their id, and Process 3 to find the relevant artists that they share in common.

![img](../resources/tut27_dataflow_layer1.png)

Figure 3 - Spotify App Dataflow (high level)


## Step 4 - Mock the dataflow execution in PureScript

Now, with our dataflow sketch at hand, we can start to code our application.  For the first part of this three-part series, we'll stop at getting our artist name arguments (i.e., Process 1) and mock the other two processes that involve HTTP Get requests.


### Getting artist names from command line arguments

To capture our artist name arguments from the command line, we use `process.argv` (see [docs](https://nodejs.org/docs/latest-v13.x/api/process.html#process_process_argv)) in Node.js directly, launching the Node.js process as

    $ node index.js Beatles Oasis

Spago, the leading PureScript package manager, has the ability to [bundle](https://github.com/purescript/spago#bundle-a-project-into-a-single-js-file) a PureScript project into a single JS file. The command for this is:

    $ spago bundle-module --main Main --to index.js

Note that I have included a `bundle` script in `package.json` to help you remember.  Invoking `npm run bundle` on the command line triggers Spago to create a single, executable, dead code eliminated `index.js`, that we can run it with Node.  From the example above, `process.argv` generates the output array:

    0: /usr/local//bin/node
    1: ~/tut27/index.js
    2: Beatles
    3: Oasis

It is the third and fourth arguments that we should capture to accomplish Process 1 in our diagram.  Moreover, we're not limited to just two artists.  So this process should be capable of capturing two or more artist names and flag an error when there are no artist names.


### Wrapping `argv` in a Task

As Brian mentions in his video, it's best to wrap `argv` in an asynchronous `Task`, whose callback delivers our artists names and handles any errors. We've used `Task` in several asynchronous programming tutorials, starting with [Tutorial 13](https://github.com/adkelley/javascript-to-purescript/tree/master/tut13). So start there if you're not familiar with this abstraction.

The main lines of code that carry out Process 1 is:

    import Node.Process (argv)
    
    type Error = String
    type Names = Array String
    
    names :: TaskE Error Names
    names =
      let
        checkArgs :: Effect (Either Error Names)
        checkArgs = do
          args <- (drop 2) <$> argv
          pure $
            if (length args > 0)
              then Right args
              else Left "you must enter at least one artist"
      in
        newTask $ \callback -> do
          checkArgs >>= \args ->
            callback $ either (\e -> rej e) (\xs -> res xs) args
          pure $ nonCanceler
    
    
    main :: Effect Unit
      void $ launchAff $
      names #
      fork (\e -> Console.error $ "Error: " <> e) (\xs -> Console.logShow xs)

Starting with our `main` function, `launchAff` launches our `names` method asynchronously, and `fork` handles one of two possible outcomes - either success or failure. Here, 'success' means that the callback returns an array with the artist names that we retrieved from the command line while 'failure' results in an error message logged to the terminal.

Within `names`, we inline a `checkArgs` function that grabs the artist names from `argv` (whose type is `Effect (Array String))`.  From [Tutorial 14](https://github.com/adkelley/javascript-to-purescript/tree/master/tut14), we know that because `argv` is an array, it is, therefore, a functor that we can map over. We `map` over `argv` to `drop` the first two items in the array.  Subsequently, there should be at least one artist name that is bound to `args`, and we check that by ensuring that the length of `args` is greater than 0. If so, then we'll wrap our artist names in a `Right` constructor from the `Either` (see [Tutorial 3](https://github.com/adkelley/javascript-to-purescript/tree/master/tut03)) monad.  If not, then wrap an error message in a `Left` constructor because, by convention, this represents failure. Finally, we wrap the result in a `Task` and clean up before returning to `main`.


### Mocking Processes 2 & 3

Referring back to our data flow diagram, Process 2 takes the artist names and searches for and returns the artist IDs. This Process requires an HTTP GET call to our Spotify search endpoint and extracts the artist IDs from the JSON response.  We'll tackle all of that in the next tutorial, but, in the meantime, we'll mock the entire data flow by wrapping each artist's name in a `Task` and wrap their fake id in another `Task`. Note that `taskOf` from `Control.Monad.Task` always returns a successful `Task`. However, you can model failure by using `taskRejected` from the same module.

    type Id = Int
    type Artist = String
    
    findArtist :: Artist -> TaskE Error Artist
    findArtist = taskOf   -- point free, assume the name is valid for now
    
    artistId :: Artist -> TaskE Error Id
    artistId _ = taskOf 10 -- return an arbitrary id

Process 3 finds the artists that are related.  Here again, we'll defer the actual work of calling the Spotify API for the next Tutorial. For now, let's just wrap an array of arbitrary artists into a `Task`.

    type RelatedArtists = Array String
    
    relatedArtists :: Id -> TaskE Error RelatedArtists
    relatedArtists id = taskOf ["John Lennon", "Paul McCartney"]

Finally, within the function `related,` we compose the entire data flow together using a couple of monadic binds, which thread our data through our three functions `findartist`, `artistId`, and `relatedArtists`; just as we see in the dataflow diagram.

    type RelatedArtists = Array String
    
    related :: String -> TaskE Error RelatedArtists
    related name = relatedArtists =<< artistId =<< findArtist name

Now, assuming there's more than one artist name to process, we need a function that traverses our array of artist names and returns all their related artists. The keyword here is `traverse` from PureScript's [Data.Traversable](https://pursuit.purescript.org/packages/purescript-foldable-traversable/4.1.1/docs/Data.Traversable#v:traverse) module, which runs our `related` method through each artist name and collects the results into a nested array of related artists.  So we'll modify our `main` function from  before to:

    main :: Effect Unit
    main = do
      void $ launchAff $
        names >>= traverse related #
        fork (\e -> Console.error $ "Error: " <> e) (\xs -> Console.logShow xs)


## Summary

In this tutorial, we began to wrap up the series by applying what we've learned about functional programming.  We used our newly acquired FP skills to develop a node application that finds commonality between two or more music artists using the Spotify API.  In the first of a three-part series, we accomplished the majority of the groundwork by 1) reviewing Spotify's API documentation; 2) testing possible endpoint responses; 3) sketching our data flow execution diagram; and 4) mocking the data flow in PureScript.  In our PureScript code, we built the functions that successfully retrieve the artist name arguments from the command line while mocking the remaining data flow.

In the next tutorial, we'll add another layer to our dataflow diagram that further illustrates the data coming to and from the Spotify API. We'll also work on replacing the mocks with the working code.  We'll also explore to find the best abstraction to handle the asynchronous API calls. As a sneak preview, let me just say that you're in for a surprise.

Finally, if you are enjoying these tutorials, then please help me to tell others by recommending this article and favoring it on [social media](https://twitter.com/adkelley/status/1195818653138046976?s=20).  Until next time.

