C = require('../lib/method-combinators')


describe "Method Combinators", ->

  describe "before", ->

    it 'should set this appropriately', ->

      decorator = C.before ->
        @foo = 'decorator'
      class BeforeClazz
        getFoo: -> @foo
        setFoo: (@foo) ->
        test:
          decorator \
          ->

      eg = new BeforeClazz()
      eg.setFoo('eg')
      eg.test()

      expect(eg.getFoo()).toBe('decorator')

    it 'should act before', ->

      decorator = C.before ->
        @foo = 'decorator'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('eg')

  describe "after", ->

    it 'should act before', ->

      decorator = C.after ->
        @foo = 'decorator'
      class BeforeClazz
        getFoo: -> @foo
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.getFoo()).toBe('decorator')

  describe "around", ->

  describe "provided", ->