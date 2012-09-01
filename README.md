method-combinators
==================

tl;dr
---

This library gives you some handy functions you can use to make [Method Decorators] in CoffeeScript or JavaScript:

[Method Decorators]: https://github.com/raganwald/homoiconic/blob/master/2012/08/method-decorators-in-coffeescript.md#method-decorators-in-coffeescript "Method Decorators in CoffeeScript"

```coffeescript

before (...) -> something
  
# => (methodBody) ->
#      (argv...) ->
#        ((...) -> something).apply(this, argv)
#        methodBody.apply(this, argv)
    
after (...) -> something

# => (methodBody) ->
#      (argv...) ->
#        __ret__ = methodBody.apply(this, argv)
#        ((...) -> something).apply(this, argv)
#        __ret__
    
around (...) -> something

# => (methodBody) ->
#      (argv...) ->
#        ((...) -> something).call(
#          this,
#          (=> methodBody.apply(this, argv)),
#          argv...
#        )

when (...) -> something

# => (methodBody) ->
#      (argv...) ->
#        if ((...) -> something).apply(this, argv)
#          methodBody.apply(this, argv)

unless (...) -> something

# => (methodBody) ->
#      (argv...) ->
#        unless ((...) -> something).apply(this, argv)
#          methodBody.apply(this, argv)

```

The library is called "Method Combinators" because these functions are isomorphic to the combinators from Combinatorial Logic.

Back up the truck, Chuck. What's a Method Decorator?
---

A method decorator is a function that takes a function as its argument and returns a new function that is to be used as a method body. For example, this is a method decorator:

```coffeescript
mustBeLoggedIn = (methodBody) ->
                   (argv...) ->
                     if currentUser
                       methodBody.apply(this, argv)
```

You use it like this:

```coffeescript

class SomeControllerLikeThing

  showUserPreferences:
    mustBeLoggedIn ->
      #
      # ... show user preferences
      #
```

And now, whenever `showUserPreferences` is called, nothing happens unless `currentUser` is truthy. And you can reuse `mustBeLoggedIn` wherever you like. Since method decorators are based on function combinators, they compose very nicely, you can write:

```coffeescript

triggersMenuRedraw = (methodBody) ->
                       (argv...) ->
                         __rval__ = methodBody.apply(this, argv)
                        @trigger('menu:redraww')
                        __rval__

class AnotherControllerLikeThing

  updateUserPreferences:
    mustBeLoggedIn \
    triggersMenuRedraw \
    ->
      #
      # ... save updated user preferences
      #
```

Fine. Method Decorators look cool. So what's a Method Combinator?
---

Method combinators are convenient function combinators for making method decorators. When writing decorators, the same few patterns tend to crop up regularly:

1. You want to do something *before* the method's base logic is executed.
2. You want to do something *after* the method's base logic is executed.
3. You want to do wrap some logic *around* the method's base logic.
4. You only want to execute the method's base logic *when* some condition is truthy.
4. You only want to execute the method's base logic *unless* some condition is truthy (The inverse of the above)

What is it?
---

CoffeeScript projects rarely need the full architecture astronautics of Aspect-Oriented Programming. Cross-cutting concerns can be untangled and expressed naturally using [Method Decorators] thanks to CoffeeScript's syntax and JavaScript's first-class functions:

Here are some example method decorators you could make with them:

```coffeescript

triggers = (eventStrings...) ->
  after ->
    for eventString in eventStrings
      @trigger(eventString)

displaysWait = do ->
  waitLevel = 0
  around (yield) ->
    someDOMElement.show() if (waitLevel += 1) > 0
    yield()
    someDOMElement.hide() if (waitLevel -= 1) <= 0

```

And here is how you might use them:

```coffeescript

class SomeExampleModel

  setHeavyweightProperty:
    triggers('cache:dirty') \
    (property, value) ->
      # set some property in a complicated way
    
  recalculate:
    displaysWait \
    triggers('cache:dirty') \
    ->
      # Do something that takes a long time
```

Method combinators 
    
There must be more to it than that
---

Nope! It's small, beautiful, and focused.

Is it any good?
---

[Yes][y].

[y]: http://news.ycombinator.com/item?id=3067434

Can I use it with pure Javascript?
---

[Yes][js].

Can I install it with npm?
---

Yes:

    npm install YouAreDaChef

Will it make me smarter?
---

No, but it can make you *appear* smarter. Just explain that *guard advice is a monad*:
    
    YouAreDaChef(EnterpriseyLegume)
    
      .when /write(.*)/, ->
        @user.hasPermission('write', match[1])

Guard advice works like a before combination, with the bonus that if it returns something falsely, the pointcut will not be executed. This behaviour is similar to the way ActiveRecord callbacks work.

You can also try making a [cryptic][cry] reference to a [computed][comp], non-local [COMEFROM][cf]. 

[cf]: http://en.wikipedia.org/wiki/COMEFROM
[cry]: http://www.reddit.com/r/programming/comments/m4r4t/aspectoriented_programming_in_coffeescript_with_a/c2yfx6w
[comp]: http://en.wikipedia.org/wiki/Goto#Computed_GOTO

[js]: https://github.com/raganwald/YouAreDaChef/blob/master/lib/YouAreDaChef.js
[gc]: https://github.com/raganwald/homoiconic/blob/master/2012/03/garbage_collection_in_coffeescript.md#readme
[blog]: https://github.com/raganwald/homoiconic/blob/master/2011/11/YouAreDaChef.md#readme

How to get started
---

Eat a hearty breakfast. Breakfast is the most important meal of the day! [:-)](https://github.com/facebook/javelin/)

Et cetera
---

YouAreDaChef was created by [Reg "raganwald" Braithwaite][raganwald]. It is available under the terms of the [MIT License][lic].

[raganwald]: http://braythwayt.com
[lic]: https://github.com/raganwald/YouAreDaChef/blob/master/license.md