method-combinators
==================

tl;dr
---

This library gives you some handy function combinators you can use to make [Method Decorators] in JavaScript (click [here](/raganwald/method-combinators/blob/master/README.md) for examples in CoffeeScript):

[Method Decorators]: https://github.com/raganwald/homoiconic/blob/master/2012/08/method-decorators-and-combinators-in-coffeescript.md#method-combinators-in-coffeescript "Method Decorators in CoffeeScript"

```coffeescript

  var __slice = [].slice;

  this.before = function(decoration) {
    return function(base) {
      return function() {
        decoration.apply(this, arguments);
        return base.apply(this, arguments);
      };
    };
  };

  this.after = function(decoration) {
    return function(base) {
      return function() {
        var __value__;
        __value__ = base.apply(this, arguments);
        decoration.apply(this, arguments);
        return __value__;
      };
    };
  };

  this.around = function(decoration) {
    return function(base) {
      return function() {
        var argv, callback, __value__,
          _this = this;
        argv = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        __value__ = void 0;
        callback = function() {
          return __value__ = base.apply(_this, argv);
        };
        decoration.apply(this, [callback].concat(argv));
        return __value__;
      };
    };
  };

  this.provided = function(condition) {
    return function(base) {
      return function() {
        if (condition.apply(this, arguments)) {
          return base.apply(this, arguments);
        }
      };
    };
  };

  this.retry = function(times) {
    return function(base) {
      return function() {
        if (!(times >= 0)) {
          return;
        }
        while (true) {
          try {
            return base.apply(this, arguments);
          } catch (error) {
            if (!times) {
              throw error;
            }
            times -= 1;
          }
        }
      };
    };
  };
```

The library is called "Method Combinators" because these functions are isomorphic to the combinators from Combinatorial Logic.

Back up the truck, Chuck. What's a Method Decorator?
---

A method decorator is a function that takes a function as its argument and returns a new function that is to be used as a method body. For example, this is a method decorator:

```javascript
mustBeLoggedIn = function (methodBody) {
  return function () {
    if (currentUser.isValid()) {
      return methodBody.apply(this, arguments)
    }
  }
}
```

You use it like this:

```javascript
function SomeControllerLikeThing() {}

SomeControllerLikeThing.prototype.showUserPreferences =
  mustBeLoggedIn(
    function() {
      //
      // ... show user preferences
      //
    }
  );
```

And now, whenever `showUserPreferences` is called, nothing happens unless `currentUser?.isValid()` is truthy. And you can reuse `mustBeLoggedIn` wherever you like. Since method decorators are based on function combinators, they compose very nicely, you can write:

```javascript
triggersMenuRedraw = function(methodBody) {
  return function () {
    var __rval__ = methodBody.apply(this, arguments);
    this.trigger('menu:redraww');
    return __rval__;
  }
};

function AnotherControllerLikeThing() {};

AnotherControllerLikeThing.prototype.updateUserPreferences =
  mustBeLoggedIn(
    triggersMenuRedraw(
      function() {
        //
        // ... save updated user preferences
        //
      }));
```

Fine. Method Decorators look cool. So what's a Method Combinator?
---

Method combinators are convenient function combinators for making method decorators. When writing decorators, the same few patterns tend to crop up regularly:

1. You want to do something *before* the method's base logic is executed.
2. You want to do something *after* the method's base logic is executed.
3. You want to do wrap some logic *around* the method's base logic.
4. You only want to execute the method's base logic *provided* some condition is truthy.
5. You want to *retry* something a certain number of times if it fails before giving up.

Method *combinators* make these common kinds of method decorators extremely easy to write. Instead of:

```javascript
mustBeLoggedIn = function (methodBody) {
  return function () {
    if (currentUser?.isValid()) {
      return methodBody.apply(this, arguments)
    }
  }
}

triggersMenuRedraw = function(methodBody) {
  return function () {
    var __rval__ = methodBody.apply(this, arguments);
    this.trigger('menu:redraww');
    return __rval__;
  }
};
```

We write:

```javascript
mustBeLoggedIn =
  provided(
    function() { return currentUser.isValid(); }
  );

triggersMenuRedraw = 
  after(
    function() { return this.trigger('menu:redraww'); }
  );
```

And they work exactly as we expect:

```javascript
function AnotherControllerLikeThing() {};

AnotherControllerLikeThing.prototype.updateUserPreferences =
  mustBeLoggedIn(
    triggersMenuRedraw(
      function() {
        //
        // ... save updated user preferences
        //
      }));
```

The combinators do the rest!

So these are like RubyOnRails controller filters?
---

There are some differences. These are much simpler, which is in keeping with JavaScript's elegant style. For example, in Rails all of the filters can abort the filter chain by returning something falsy. The `before` and `after` decorators don't act as filters. Use `provided` if that's what you want.

More specifically:

* None of the decorators you build with the method combinators change the arguments passed to the method. The `before` and `around` callbacks can execute code before the method body is executed, but only for side-effects.
* The `provided` decorator will return `void 0` if it evaluates to falsy or return whatever the method body returns. There's no other way to change the return value with `provided`
* The `around` decorator will return `void 0` if you don't call the passed callback. Otherwise, it returns whatever the method body would return. You can't change its arguments or the return value. You don't need to pass arguments to the callback. If you do, they will be ignored.

Is it any good?
---

[Yes][y].

[y]: http://news.ycombinator.com/item?id=3067434

[js]: https://github.com/raganwald/method-combinators/blob/master/lib/method-combinators.js

Can I install it with npm?
---

Yes: `npm install method-combinators`

How to get started
---

Eat a hearty breakfast. Breakfast is the most important meal of the day! [:-)](https://github.com/facebook/javelin/)

Et cetera
---

Method Combinators was created by [Reg "raganwald" Braithwaite][raganwald]. It is available under the terms of the [MIT License][lic].

[raganwald]: http://braythwayt.com
[lic]: https://github.com/raganwald/YouAreDaChef/blob/master/license.md