Method Combinators in an Asynchronous World
===========================================

The standard [method combinators] make a fairly obvious assumption: That the methods being "decorated" are synchronous, meaning, they execute and return when they are done. Methods that perform an asynchronous action such as performing an XMLHttpRequest may return immediately without waiting for the request to complete.

[method combinators]: https://github.com/raganwald/method-combinators

One pattern for dealing with this is "callback-oriented programming," as popularized by [node.js][node][[1](#notes)] (click [here](http:async.md) for examples in CoffeeScript):

[node]: http://nodejs.org/

```javascript
var myExampleObject;

myExampleObject = {
  name: 'Jerry Seinfeld',
  occupation: 'Comedian',
  update: function(callback) {
    if (callback == null) {
      callback = function() {};
    }
    return jQuery.get('http://example.com/comedians/jseinfeld.json', {}, function(data) {
      this.name = data.name;
      this.occupation = data.occupation;
      return callback();
    });
  }
};
```

(This is clearly not a practical code snippet, it's intended to be just sane enough to use as an example.)

The **async** combinators help you make method decorators for methods that use callback-oriented programming. You can use this callback parameter as you would when doing any other Node-like programming. In addition, you can now decorate the method using async combinators:

```javascript
var hidesWait, myExampleObject, showsWait;

showsWait = async.before(function(callback) {
  jQuery('img#wait').show();
  return callback();
});

hidesWait = async.after(function(callback) {
  jQuery('img#wait').show();
  return callback();
});

myExampleObject = {
  name: 'Jerry Seinfeld',
  occupation: 'Actor',
  update: showsWait(hidesWait(function() {
    return jQuery.get('http://example.com/comedians/jseinfeld.json', {}, function(data) {
      this.name = data.name;
      return this.occupation = data.occupation;
    });
  }))
};

myExampleObject.update(function() {
  return alert("Jerry's new occupation is " + myExampleObject.occupation);
});
```

In this case, we're showing some kind of "wait" image (perhaps a spinning gif) when we call the method, and hiding it after we receive the update. The async combinators are "callback-aware," so the gif will be hidden just before the alert is displayed.

Async Combinators
-----------------

The following combinators work with methods (or functions!) that follow the standard callback-pattern: First, the method's last parameter is a callback function. Second, the callback function is called when the method completes its processing:

```javascript
async.before = function(async_decoration) {
  return function(async_base) {
    return function() {
      var apply_base, argv, callback, __value__, _i,
        _this = this;
      argv = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      __value__ = void 0;
      apply_base = function() {
        return __value__ = async_base.apply(_this, argv.concat(callback));
      };
      async_decoration.apply(this, argv.concat(apply_base));
      return __value__;
    };
  };
};
async.after = function(async_decoration) {
  return function(async_base) {
    return function() {
      var argv, callback, decorated_callback, _i,
        _this = this;
      argv = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      decorated_callback = function() {
        var callback_argv;
        callback_argv = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return async_decoration.apply(_this, callback_argv.concat(function() {
          return callback.apply(this, callback_argv);
        }));
      };
      return async_base.apply(this, argv.concat(decorated_callback));
    };
  };
};
async.provided = function(async_predicate) {
  return function(async_base) {
    return function() {
      var argv, callback, decorated_base, _i;
      argv = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      decorated_base = function(predicate_value) {
        if (predicate_value) {
          return async_base.apply(this, argv.concat(callback));
        } else {
          return callback();
        }
      };
      return async_predicate.apply(this, argv.concat(decorated_base));
    };
  };
};
```

Async Helpers
-------------

The async combinators all work with a callback-oriented method and a callback-oriented decoration. This allows you to do things like write a `provided` decorator that requests confirmation from a user or authorization from a server.

If you want to use a synchronous function as decoration, the `async` helper will convert it into a callback-oriented function:

```javascript
async = function(fn) {
  return function() {
    var argv, callback, _i;
    argv = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
    return callback(fn.apply(this, argv));
  };
};
```

For example, instead of:

```javascript
var showsWait;

showsWait = async.before(function(callback) {
  jQuery('img#wait').show();
  return callback();
});
```

You can—if you prefer—write:

```javascript
var showsWait;

showsWait = async.before(async(function() {
  return jQuery('img#wait').show();
}));
```

Notes
-----

1. Another, more sophisticated approach uses Promises or [Deferred Objects]. Future method combinators may interoperate with deferred objects.

[Deferred Objects]:http://api.jquery.com/category/deferred-object/