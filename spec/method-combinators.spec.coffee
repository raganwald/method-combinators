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

  describe "provided", ->

    it 'should set this appropriately', ->

      decorator = C.provided ->
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

      decorator = C.provided ->
        @foo = 'decorated'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

    it 'should guard', ->

      decorator = C.provided (what) ->
        what is 'foo'
        
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('foo')
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('foo')