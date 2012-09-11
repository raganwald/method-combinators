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