# # Method Combinators
#
# Source: https://github.com/raganwald/method-combinators
#
# ## The four basic combinators

this.before =
  (decoration) ->
    (base) ->
      ->
        decoration.apply(this, arguments)
        base.apply(this, arguments)

this.after =
  (decoration) ->
    (base) ->
      ->
        decoration.call(this, __value__ = base.apply(this, arguments))
        __value__

this.around =
  (decoration) ->
    (base) ->
      (argv...) ->
        __value__ = undefined
        apply_base = =>
          __value__ = base.apply(this, argv)
        decoration.apply(this, [apply_base].concat(argv))
        __value__

this.provided =
  (predicate) ->
    (base) ->
      ->
        if predicate.apply(this, arguments)
          base.apply(this, arguments)

# ## Extras

# If the method thows an error, retry it again a certain number of times.
# e.g. `retry(3) -> # doSomething as many as four times`
this.retry =
  (times) ->
    (base) ->
      ->
        return unless times >= 0
        loop
          try
            return base.apply(this, arguments)
          catch error
            throw error unless (times -= 1) >= 0

# Throw an error before the method is executed if the prepredicate function fails, with an
# optional message, e.g. `prepredicate 'account must be valid', -> @account.isValid()` or
# `prepredicate -> @account.isValid()`
this.precondition =
  (throwable, predicate) ->
    (predicate = throwable) and (throwable = 'Failed precondition') unless predicate
    this.before -> throw throwable unless predicate.apply(this, arguments)

# Throw an error after the method is executed if the postpredicate function fails, with an
# optional message, e.g. `postpredicate 'account must be valid', -> @account.isValid()` or
# `postpredicate -> @account.isValid()`
this.postcondition =
  (throwable, predicate) ->
    (predicate = throwable) and (throwable = 'Failed postcondition') unless predicate
    this.after -> throw throwable unless predicate.apply(this, arguments)

# ## Asynchronous Method Combinators

this.async = do (async = undefined) ->

  async = (fn) ->
    (argv..., callback) ->
      callback(fn.apply(this, argv))

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
          async_decoration.apply(this, argv.concat(-> callback.apply(this, callback_argv)))
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

  async