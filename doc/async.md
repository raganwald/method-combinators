Method Combinators in an Asynchronous World
===========================================

(These examples are in CoffeeScript. Click [here](https://github.com/raganwald/method-combinators/blob/master/doc/async-js.md#method-combinators-in-an-asynchronous-world) for examples in JavaScript.)

The standard [method combinators] make a fairly obvious assumption: That the methods being "decorated" are synchronous, meaning, they execute and return when they are done. Methods that perform an asynchronous action such as performing an XMLHttpRequest may return immediately without waiting for the request to complete.

[method combinators]: https://github.com/raganwald/method-combinators

One pattern for dealing with this is "callback-oriented programming," as popularized by [node.js][node]([1](#notes)). This is clearly not a practical code snippet, it's intended to be just sane enough to use as an example:

[node]: http://nodejs.org/

```coffeescript
myFunnyObject =
  name: 'Jerry Seinfeld'
  occupation: 'Comedian'
  update: (callback = ->) ->
    jQuery.get 'http://example.com/comedians/jseinfeld.json', {}, (data) ->
      @name = data.name
      @occupation = data.occupation
      callback()
```

The **async** combinators help you make method decorators for methods that use callback-oriented programming.([2](#notes)) You can use this callback parameter as you would when doing any other Node-like programming. In addition, you can now decorate the method using async combinators:

```coffeescript
showsWait = async.before (callback) ->
  jQuery('img#wait').show()
  callback()
hidesWait = async.after (callback) ->
  jQuery('img#wait').show()
  callback()
  
myFunnyObject =
  name: 'Jerry Seinfeld'
  occupation: 'Actor'
  update: showsWait hidesWait ->
    jQuery.get 'http://example.com/comedians/jseinfeld.json', {}, (data) ->
      @name = data.name
      @occupation = data.occupation
      
myFunnyObject.update ->
  alert "Jerry's new occupation is #{myFunnyObject.occupation}"
```

In this case, we're showing some kind of "wait" image (perhaps a spinning gif) when we call the method, and hiding it after we receive the update. The async combinators are "callback-aware," so the gif will be hidden just before the alert is displayed.

Async Combinators
-----------------

The following combinators work with methods (or functions!) that follow the standard callback-pattern: First, the method's last parameter is a callback function. Second, the callback function is called when the method completes its processing:

```coffeescript
async.before = (async_decoration) ->
  (async_base) ->
    (argv..., callback) ->
      __value__ = undefined
      apply_base = =>
        __value__ = async_base.apply(this, argv.concat(callback))
      async_decoration.apply(this, argv.concat(apply_base))
      __value__

async.after = (async_decoration) ->
  (async_base) ->
    (argv..., callback) ->
      decorated_callback = (callback_argv...) =>
        async_decoration.apply(this, callback_argv.concat(-> callback.apply(this, callback_argv)))
      async_base.apply(this, argv.concat(decorated_callback))

async.provided = (async_predicate) ->
  (async_base) ->
    (argv..., callback) ->
      decorated_base = (predicate_value) ->
        if predicate_value
          async_base.apply(this, argv.concat(callback))
        else
          callback()
      async_predicate.apply(this, argv.concat(decorated_base))
```

Async Helpers
-------------

The async combinators all work with a callback-oriented method and a callback-oriented decoration. This allows you to do things like write a `provided` decorator that requests confirmation from a user or authorization from a server.

If you want to use a synchronous function as decoration, the `async` helper will convert it into a callback-oriented function:

```coffeescript
async = (fn) ->
  (argv..., callback) ->
    callback(fn.apply(this, argv))
```

For example, instead of:

```coffeescript
showsWait = async.before (callback) ->
  jQuery('img#wait').show()
  callback()
```

You can—if you prefer—write:

```coffeescript
showsWait = async.before async -> 
  jQuery('img#wait').show()
```

On a very small example like this, the difference is one of taste. On larger, more complex functions with multiple paths of termination, the `async` helper is very useful.

post scriptum
-------------

I'm writing a book called [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto). Check it out!

Notes
-----

1. Another, more sophisticated approach uses Promises or [Deferred Objects]. Future method combinators may interoperate with deferred objects.
2. The async combinators are based largely on work by [Nate Murray](https://github.com/jashmenn).

[Deferred Objects]:http://api.jquery.com/category/deferred-object/