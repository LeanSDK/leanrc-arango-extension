{ db }  = require '@arangodb'
EventEmitter = require 'events'

{ expect, assert } = require 'chai'
sinon = require 'sinon'
mimeTypes = require 'mime-types'

LeanRC = require '@leansdk/leanrc'

ArangoExtension = require '../../..'

{
  FuncG, TupleG
  Utils: { co }
} = LeanRC::

PREFIX = module.context.collectionPrefix


describe 'ArangoSwitchMixin', ->
  describe '.new', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
    after ->
      db._drop "#{PREFIX}tests"
    it 'should create switch instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
        Test.initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
        TestSwitch.initialize()
        testSwitch = TestSwitch.new()
        assert.instanceOf testSwitch, TestSwitch
        yield return
  ### TODO: Move to ArangoResourceMixin
  describe '#getLocks', ->
    before ->
      db._createDocumentCollection 'test_tests1'
      db._createDocumentCollection 'test_tests2'
      db._createDocumentCollection 'test_tests3'
      db._createDocumentCollection 'test_tests4'
    after ->
      db._drop 'test_tests1'
      db._drop 'test_tests2'
      db._drop 'test_tests3'
      db._drop 'test_tests4'
    it 'should get locks for collections', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
        Test.initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
        TestSwitch.initialize()
        testSwitch = TestSwitch.new()
        locks = testSwitch.getLocks()
        assert.deepEqual locks,
          read: [ 'test_tests1', 'test_tests2', 'test_tests3', 'test_tests4' ]
          write: [ 'test_tests1', 'test_tests2', 'test_tests3', 'test_tests4' ]
        yield return
  ###
  describe '#del', ->
    it 'should alias to #delete', ->
      co ->
        spyDelete = sinon.spy -> [{}, {}]
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
          @public delete: FuncG([String, Function], TupleG Object, Object), { default: spyDelete }
          @initialize()
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.del 'TEST', (->)
        assert.isTrue spyDelete.calledWith 'TEST'
        yield return
  describe '#respond', ->
    facade = null
    KEY = 'TEST_ARANGO_SWITCH_MIXIN_001'
    after -> facade?.remove?()
    it 'should send response', ->
      co ->
        trigger = new EventEmitter
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestConfiguration extends Test::Configuration
          @inheritProtected()
          @include Test::ArangoConfigurationMixin
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
          @initialize()
        class TestContext extends Test::ArangoContext
          @inheritProtected()
          @module Test
          @initialize()
        configs = TestConfiguration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res =
          type: (value) ->
            if arguments.length is 0
              @getHeader 'Content-Type'
            else
              type = (mimeTypes.lookup value) or value
              if type?
                @setHeader 'Content-Type', type
              else
                @removeHeader 'Content-Type'
          headers: {}
          status: (code) -> @statusCode = code
          set: (headers) ->
            for headerName, headerValue of headers ? {}
              @setHeader headerName, headerValue
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data) -> trigger.emit 'end', data
          send: (args...) -> @end args...
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier KEY
        context = TestContext.new req, res, switchMediator
        context.body = test: 'test'
        context.set 'Content-Type', 'application/json'
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        switchMediator.respond context
        data = yield endPromise
        assert.deepEqual data, test: 'test'
        yield return
  describe '#sender', ->
    facade = null
    KEY = 'TEST_ARANGO_SWITCH_MIXIN_002'
    after -> facade?.remove?()
    it 'should send notification', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestConfiguration extends Test::Configuration
          @inheritProtected()
          @include Test::ArangoConfigurationMixin
          @module Test
          @initialize()
        configs = TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
          @initialize()
        class TestContext extends Test::ArangoContext
          @inheritProtected()
          @module Test
          @initialize()
        configs = TestConfiguration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res =
          type: (value) ->
            if arguments.length is 0
              @getHeader 'Content-Type'
            else
              type = (mimeTypes.lookup value) or value
              if type?
                @setHeader 'Content-Type', type
              else
                @removeHeader 'Content-Type'
          headers: {}
          status: (code) -> @statusCode = code
          set: (headers) ->
            for headerName, headerValue of headers ? {}
              @setHeader headerName, headerValue
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier KEY
        context = TestContext.new req, res, switchMediator
        spySwitchSendNotification = sinon.spy switchMediator, 'sendNotification'
        vhParams =
          context: context
          reverse: 'TEST_REVERSE'
        vhOptions =
          method: 'GET'
          path: '/test'
          resource: 'test'
          action: 'list'
          tag: ''
          template: 'test/list'
          keyName: null
          entityName: 'test'
          recordName: 'test'
        switchMediator.sender 'test', vhParams, vhOptions
        assert.isTrue spySwitchSendNotification.called, 'Notification not sent'
        assert.deepEqual spySwitchSendNotification.args[0], [
          'test'
          {
            context: context
            reverse: 'TEST_REVERSE'
          }
          'list'
        ]
        yield return
  describe '.createMethod', ->
    it 'should create method for add native router', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @createMethod 'test'
        TestSwitch.initialize()
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        assert.property switchMediator, 'test'
        assert.isFunction switchMediator.test
        yield return
  describe '#onRegister', ->
    facade = null
    KEY = 'TEST_ARANGO_SWITCH_MIXIN_003'
    after -> facade?.remove?()
    it 'should run on-register flow', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestConfiguration extends Test::Configuration
          @inheritProtected()
          @include Test::ArangoConfigurationMixin
          @module Test
        TestConfiguration.initialize()
        configs = TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        spyDefineRoutes = sinon.spy switchMediator, 'defineRoutes'
        switchMediator.initializeNotifier KEY
        switchMediator.onRegister()
        assert.isTrue spyDefineRoutes.called
        assert.instanceOf switchMediator.getViewComponent(), EventEmitter
        assert.lengthOf switchMediator.getViewComponent().listeners('error'), 1
        yield return
  describe '#onRemove', ->
    facade = null
    KEY = 'TEST_ARANGO_SWITCH_MIXIN_004'
    after ->
      facade?.remove?()
      console.log 'ArangoSwitchMixin TESTS END'
    it 'should run on-remove flow', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestConfiguration extends Test::Configuration
          @inheritProtected()
          @include Test::ArangoConfigurationMixin
          @module Test
        TestConfiguration.initialize()
        configs = TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        switchMediator = TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        spyDefineRoutes = sinon.spy switchMediator, 'defineRoutes'
        switchMediator.initializeNotifier KEY
        switchMediator.onRegister()
        assert.isTrue spyDefineRoutes.called
        assert.instanceOf switchMediator.getViewComponent(), EventEmitter
        assert.lengthOf switchMediator.getViewComponent().listeners('error'), 1
        switchMediator.onRemove()
        assert.lengthOf switchMediator.getViewComponent().listeners('error'), 0
        yield return
