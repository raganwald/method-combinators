C = require('../lib/method-combinators')

describe "Method Combinators", ->

  describe "before", ->

    it 'should set this appropriately', ->

      decorator = C.before ->
        @foo = 'decorated'
      class BeforeClazz
        setFoo: (@foo) ->
        test:
          decorator \
          ->

      eg = new BeforeClazz()
      eg.setFoo('eg')
      eg.test()

      expect(eg.foo).toBe('decorated')

    it 'should act before', ->

      decorator = C.before ->
        @foo = 'decorated'
      class BeforeClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.foo).toBe('eg')

    it 'should not guard', ->

      decorator = C.before -> false

      class BeforeClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.foo).toBe('eg')

    it 'should be paramaterized by the arguments', ->

      decorator = C.before (foo, bar) ->
        expect(foo).toBe 'foo'
        expect(bar).toBe 'bar'

      class BeforeClazz
        noop: decorator -> 'blitz'

      eg = new BeforeClazz()
      eg.noop 'foo', 'bar'

  describe "after", ->

    it 'should act after', ->

      decorator = C.after ->
        @foo = 'decorated'
      class BeforeClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.foo).toBe('decorated')

    it 'should not filter', ->

      decorator = C.after ->
        'decorated'
      class BeforeClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.foo).toBe('eg')

    it 'should be paramaterized by the return value', ->

      decorator = C.after (foo, bar) ->
        expect(foo).not.toBe 'foo'
        expect(bar).not.toBe 'bar'
        expect(foo).toBe 'blitz'

      class BeforeClazz
        noop: decorator -> 'blitz'

      eg = new BeforeClazz()
      eg.noop 'foo', 'bar'

  describe "around", ->

    it 'should not filter parameters', ->

      decorator = C.around (callback)->
        callback('decorated')
      class BeforeClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new BeforeClazz()
      eg.setFoo('eg')

      expect(eg.foo).toBe('eg')

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

      expect(eg.foo).toBe('eg')

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

      expect(eg.foo).toBe('eg')

  describe "provided", ->

    it 'should guard', ->

      decorator = C.provided (what) ->
        what is 'foo'

      class ProvidedClazz
        setFoo:
          decorator \
          (@foo) ->

      eg = new ProvidedClazz()
      eg.setFoo('foo')
      eg.setFoo('eg')

      expect(eg.foo).toBe('foo')

  describe "retry", ->

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

  describe 'precondition', ->

    it 'should throw error', ->

      mustBeSane = C.precondition 'must be sane', -> @sane

      class TestClazz
        constructor: (@sane) ->
        setSanity:
          mustBeSane \
          (@sane) ->

      insane = new TestClazz(false)
      expect(-> insane.setSanity(true)).toThrow 'must be sane'
      expect(-> insane.setSanity(false)).toThrow 'must be sane'

    it 'should throw error', ->

      mustBeSane = C.precondition 'must be sane', -> @sane

      class TestClazz
        constructor: (@sane) ->
        setSanity:
          mustBeSane \
          (@sane) ->

      sane = new TestClazz(true)
      expect(-> sane.setSanity(true)).not.toThrow 'must be sane'
      expect(-> sane.setSanity(false)).not.toThrow 'must be sane'

    it 'should work without a message', ->

      mustBeSane = C.precondition -> @sane

      class TestClazz
        constructor: (@sane) ->
        setSanity:
          mustBeSane \
          (@sane) ->

      insane = new TestClazz(false)
      expect(-> insane.setSanity(true)).toThrow 'Failed precondition'
      expect(-> insane.setSanity(false)).toThrow 'Failed precondition'
      sane = new TestClazz(true)
      expect(-> sane.setSanity(true)).not.toThrow 'Failed precondition'
      expect(-> sane.setSanity(false)).not.toThrow 'Failed precondition'

describe "Asynchronous Method Combinators", ->

  a = undefined

  beforeEach ->
    a = []

  addn = (n) ->
    a.push(n)

  add2 = ->
    a.push(2)

  describe "async(...)", ->

    it "should convert a fn to an async_fn", ->

      C.async(addn)(1, add2)

      expect(a).toEqual([1,2])

  describe "async.before", ->

    it "should handle the most base case", ->

      decoration = C.async ->
        a.push('before')
      base = C.async ->
        a.push('base')

      decorate = C.async.before(decoration)

      decorate(base) ->

      expect(a).toEqual(['before', 'base'])

    it "should pass the result as a parameter", ->

      decoration = C.async (p) ->
        a.push('before/' + p)
        'throw me away'
      base = C.async (p) ->
        a.push('base/' + p)
        'result'

      decorate = C.async.before(decoration)

      decorate(base) 'parameter', (p) ->
        a.push('callback/' + p)

      expect(a).toEqual(['before/parameter', 'base/parameter', 'callback/result'])

  describe "async.after", ->

    it "should handle the most base case", ->

      decoration = C.async ->
        a.push('after')
      base = C.async ->
        a.push('base')

      decorate = C.async.after(decoration)

      decorate(base) ->

      expect(a).toEqual(['base', 'after'])

    it "should pass the result as a parameter", ->

      decoration = C.async (p) ->
        a.push('after/' + p)
        'throw me away'
      base = C.async (p) ->
        a.push('base/' + p)
        'result'

      decorate = C.async.after(decoration)

      decorate(base) 'parameter', (p) ->
        a.push('callback/' + p)

      expect(a).toEqual(['base/parameter', 'after/result', 'callback/result'])

  describe "async.provided", ->

    predicate = C.async (p) -> p is 'yes'
    decorate = C.async.provided(predicate)

    describe "for the base case", ->

      base = C.async ->
        a.push('base')

      it "should handle the true case", ->

        decorate(base) 'yes', ->

        expect(a).toEqual(['base'])

      it "should handle the false case", ->

        decorate(base) 'no', ->

        expect(a).toEqual([])
