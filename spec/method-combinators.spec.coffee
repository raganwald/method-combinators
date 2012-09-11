C = require('../lib/method-combinators')


describe "Method Combinators", ->

  describe "before", ->

    it 'should set this appropriately', ->

      decorator = C.before ->
        @foo = 'decorated'
      class BeforeClazz
        getFoo: -> @foo
        setFoo: (@foo) ->
        test:
          decorator \
          ->

      eg = new BeforeClazz()
      eg.setFoo('eg')
      eg.test()

      expect(eg.getFoo()).toBe('decorated')

    it 'should act before', ->

      decorator = C.before ->
        @foo = 'decorated'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

    it 'should not guard', ->

      decorator = C.before -> false

      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

  describe "after", ->

    it 'should act after', ->

      decorator = C.after ->
        @foo = 'decorated'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('decorated')

    it 'should not filter', ->

      decorator = C.after ->
        'decorated'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

  describe "around", ->

    it 'should not filter parameters', ->

      decorator = C.around (callback)->
        callback('decorated')
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

    it 'should return what the callback returns', ->

      decorator = C.around (callback)->
        callback()
        'decorated'
      class BeforeClazz
        getFoo:
          decorator \
          -> @foo
        setFoo: (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

    it 'should not change the arguments', ->

      decorator = C.around (callback)->
        callback('decorated')
      class BeforeClazz
        getFoo:
          decorator \
          -> @foo
        setFoo: (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

  describe "provided", ->

    it 'should set this appropriately', ->

      decorator = C.provided ->
        @foo = 'decorated'
      class ProvidedClazz
        getFoo: -> @foo
        setFoo: (@foo) ->
        test:
          decorator \
          ->

      eg = new ProvidedClazz()
      eg.setFoo('eg')
      eg.test()

      expect(eg.getFoo()).toBe('decorated')

    it 'should act before', ->

      decorator = C.provided ->
        @foo = 'decorated'
      class ProvidedClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new ProvidedClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

    it 'should guard', ->

      decorator = C.provided (what) ->
        what is 'foo'

      class ProvidedClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new ProvidedClazz()
      eg.setFoo('foo')
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('foo')

  describe "try", ->

    describe 'times < 0', ->

      it 'should return nothing', ->

        class TryClazz
          foo:
            C.retry(-42) \
            -> 'foo'

        eg = new TryClazz()

        expect(eg.foo()).toBe(undefined)

    describe 'times == 0', ->

      it 'should return if there is no error', ->

        class TryClazz
          foo:
            C.retry(0) \
            -> 'foo'

        eg = new TryClazz()

        expect(eg.foo()).toBe('foo')

      it 'should return if there is no error', ->

        class TryClazz
          foo:
            C.retry(0) \
            ->
              throw 'bogwash'

        eg = new TryClazz()

        expect(-> eg.foo()).toThrow 'bogwash'

    describe 'times > 0', ->

      it 'should return if there is no error', ->

        class TryClazz
          foo:
            C.retry(6) \
            -> 'foo'

        eg = new TryClazz()

        expect(eg.foo()).toBe('foo')

      it 'should return if there is no error', ->

        class TryClazz
          foo:
            C.retry(6) \
            ->
              throw 'bogwash'

        eg = new TryClazz()

        expect(-> eg.foo()).toThrow 'bogwash'

      it 'should throw an error if we don\'t have enough retries', ->

        class TryClazz
          constructor: (@times_to_fail) ->
          foo:
            C.retry(6) \
            ->
              if (@times_to_fail -= 1) >= 0
                throw 'fail'
              else
                'succeed'

        eg = new TryClazz(7) # first try plus six retries and still fails

        expect(-> eg.foo()).toThrow 'fail'

      it 'should return if we have enough retries', ->

        class TryClazz
          constructor: (@times_to_fail) ->
          foo:
            C.retry(6) \
            ->
              if (@times_to_fail -= 1) >= 0
                throw 'fail'
              else
                'succeed'

        eg = new TryClazz(6)

        expect(eg.foo()).toBe 'succeed'

