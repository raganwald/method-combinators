# The four basic combinators

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
        __value__ = base.apply(this, arguments)
        decoration.apply(this, arguments)
        __value__

this.around =
  (decoration) ->
    (base) ->
      (argv...) ->
        __value__ = undefined
        callback = =>
          __value__ = base.apply(this, argv)
        decoration.apply(this, [callback].concat(argv))
        __value__

this.provided =
  (condition) ->
    (base) ->
      ->
        if condition.apply(this, arguments)
          base.apply(this, arguments)

# Extras

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

# throw an error before the method is executed if the precondition function fails, with an
# optional message, e.g. `precondition 'account must be valid', -> @account.isValid()` or
# `precondition -> @account.isValid()`
this.precondition =
  (throwable, condition) ->
    (condition = throwable) and (throwable = 'Failed precondition') unless condition
    this.before -> throw throwable unless condition.apply(this, arguments)

# throw an error after the method is executed if the postcondition function fails, with an
# optional message, e.g. `postcondition 'account must be valid', -> @account.isValid()` or
# `postcondition -> @account.isValid()`
this.postcondition =
  (throwable, condition) ->
    (condition = throwable) and (throwable = 'Failed postcondition') unless condition
    this.after -> throw throwable unless condition.apply(this, arguments)