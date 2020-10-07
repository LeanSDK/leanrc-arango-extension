{ Readable } = require 'stream'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
accepts = require 'accepts'
mimeTypes = require 'mime-types'
contentDisposition = require 'content-disposition'
status = require 'statuses'
LeanRC = require '@leansdk/leanrc'
EventEmitter = require 'events'
ArangoExtension = require '../../..'

{ co } = LeanRC::Utils
MIME_BINARY = 'application/octet-stream'


describe 'ArangoResponse', ->
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create Response instance', ->
      co ->
        KEY = 'TEST_RESPONSE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context = {}
        response = TestResponse.new context
        assert.instanceOf response, TestResponse
        yield return
  describe '#ctx', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get context object', ->
      co ->
        KEY = 'TEST_RESPONSE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context = {}
        response = TestResponse.new context
        assert.equal response.ctx, context
        yield return
  describe '#res', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get native resource object', ->
      co ->
        KEY = 'TEST_RESPONSE_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res = {}
        # context = { res }
        response = TestResponse.new context
        assert.equal response.res, res
        yield return
  describe '#switch', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get switch object', ->
      co ->
        KEY = 'TEST_RESPONSE_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # switchObject = {}
        # context = switch: switchObject
        response = TestResponse.new context
        assert.equal response.switch, switchMediator
        yield return
  describe '#socket', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get socket object', ->
      co ->
        KEY = 'TEST_RESPONSE_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        socket = {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
          socket: socket
        context = Test::Context.new req, res, switchMediator
        # context = req: {}
        response = TestResponse.new context
        assert.isUndefined response.socket
        yield return
  describe '#headerSent', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get res.headersSent value', ->
      co ->
        KEY = 'TEST_RESPONSE_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          headersSent: no
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res = headersSent: no
        # context = { res }
        response = TestResponse.new context
        assert.equal response.headerSent, res.headersSent
        yield return
  describe '#headers', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get response headers', ->
      co ->
        KEY = 'TEST_RESPONSE_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'Foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        # context = { res }
        response = TestResponse.new context
        assert.deepEqual response.headers, 'Foo': 'Bar'
        yield return
  describe '#header', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get response headers', ->
      co ->
        KEY = 'TEST_RESPONSE_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'Foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        # context = { res }
        response = TestResponse.new context
        assert.deepEqual response.header, 'Foo': 'Bar'
        yield return
  describe '#status', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response status', ->
      co ->
        KEY = 'TEST_RESPONSE_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          statusCode: 200
          statusMessage: 'OK'
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        # context = { res }
        response = TestResponse.new context
        assert.equal response.status, 200
        response.status = 400
        assert.equal response.status, 400
        assert.equal res.statusCode, 400
        assert.throws -> response.status = 'TEST'
        assert.throws -> response.status = 0
        assert.doesNotThrow -> response.status = 200
        # res.headersSent = yes
        # assert.throws -> response.status = 200
        yield return
  describe '#message', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response message', ->
      co ->
        KEY = 'TEST_RESPONSE_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          statusCode: 200
          statusMessage: 'OK'
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        # context = { res }
        response = TestResponse.new context
        assert.equal response.message, 'OK'
        response.message = 'TEST'
        assert.equal response.message, 'TEST'
        assert.equal res.statusMessage, 'TEST'
        yield return
  describe '#get', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get specified response header', ->
      co ->
        KEY = 'TEST_RESPONSE_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        # context = { res }
        response = TestResponse.new context
        assert.deepEqual response.get('Foo'), 'Bar'
        yield return
  describe '#set', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set specified response header', ->
      co ->
        KEY = 'TEST_RESPONSE_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        # context = { res }
        response = TestResponse.new context
        response.set 'Content-Type', 'text/plain'
        assert.equal res.headers['content-type'], 'text/plain'
        assert.equal response.get('Content-Type'), 'text/plain'
        now = new Date
        response.set 'Date', now
        assert.equal response.get('Date'), "#{now}"
        array = [ 1, now, 'TEST']
        response.set 'Test', array
        assert.deepEqual response.get('Test'), [ '1', "#{now}", 'TEST']
        response.set
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
        assert.equal response.get('Abc'), '123'
        assert.equal response.get('Last-Date'), "#{now}"
        assert.equal response.get('New-Test'), 'Test'
        yield return
  describe '#append', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should add specified response header value', ->
      co ->
        KEY = 'TEST_RESPONSE_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        # context = { res }
        response = TestResponse.new context
        response.append 'Test', 'data'
        assert.equal response.get('Test'), 'data'
        response.append 'Test', 'Test'
        assert.deepEqual response.get('Test'), [ 'data', 'Test' ]
        response.append 'Test', 'Test'
        assert.deepEqual response.get('Test'), [ 'data', 'Test', 'Test' ]
        yield return
  describe '#remove', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove specified response header', ->
      co ->
        KEY = 'TEST_RESPONSE_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        response.set 'Test', 'data'
        assert.equal response.get('Test'), 'data'
        response.remove 'Test'
        assert.equal response.get('Test'), ''
        yield return
  describe '#vary', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `Vary` header', ->
      co ->
        KEY = 'TEST_RESPONSE_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          vary: (value) -> @setHeader 'Vary', value
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   vary: (value) -> @setHeader 'Vary', value
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        # context = { res }
        response = TestResponse.new context
        response.vary 'Origin'
        assert.equal response.get('Vary'), 'Origin'
        yield return
  describe '#lastModified', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set `Last-Modified` header', ->
      co ->
        KEY = 'TEST_RESPONSE_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        # context = { res }
        response = TestResponse.new context
        now = new Date
        response.lastModified = now
        assert.equal res.headers['last-modified'], now.toUTCString()
        assert.deepEqual response.lastModified, new Date now.toUTCString()
        yield return
  describe '#etag', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set `ETag` header', ->
      co ->
        KEY = 'TEST_RESPONSE_017'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: 'foo': 'Bar'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        # context = { res }
        response = TestResponse.new context
        etag = '123456789'
        response.etag = etag
        assert.equal res.headers['etag'], "\"#{etag}\""
        assert.deepEqual response.etag, "\"#{etag}\""
        etag = 'W/"123456789"'
        response.etag = etag
        assert.equal res.headers['etag'], etag
        assert.deepEqual response.etag, etag
        yield return
  describe '#type', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get, set and remove `Content-Type` header', ->
      co ->
        KEY = 'TEST_RESPONSE_018'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        assert.equal response.type, ''
        response.type = 'markdown'
        assert.equal response.type, 'text/markdown'
        assert.equal res.headers['content-type'], 'text/markdown; charset=utf-8'
        response.type = 'file.json'
        assert.equal response.type, 'application/json'
        assert.equal res.headers['content-type'], 'application/json; charset=utf-8'
        response.type = 'text/html'
        assert.equal response.type, 'text/html'
        assert.equal res.headers['content-type'], 'text/html; charset=utf-8'
        response.type = null
        assert.equal response.type, ''
        assert.isUndefined res.headers['content-type']
        yield return
  describe '#attachment', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should setup attachment', ->
      co ->
        KEY = 'TEST_RESPONSE_019'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          type: (value) ->
            if arguments.length is 0
              @getHeader 'Content-Type'
            else
              type = (mimeTypes.lookup value) or value
              if type?
                @setHeader 'Content-Type', type
              else
                @removeHeader 'Content-Type'
          attachment: (filename) ->
            @setHeader 'Content-Disposition', contentDisposition filename
            if filename and not @getHeader 'Content-Type'
              @setHeader 'Content-Type', (mimeTypes.lookup filename) or MIME_BINARY
            @
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   attachment: (filename) ->
        #     @setHeader 'Content-Disposition', contentDisposition filename
        #     if filename and not @getHeader 'Content-Type'
        #       @setHeader 'Content-Type', (mimeTypes.lookup filename) or MIME_BINARY
        #     @
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        response.attachment "#{__dirname}/#{__filename}"
        assert.equal response.type, 'application/javascript'
        assert.equal response.get('Content-Disposition'), 'attachment; filename="ArangoResponse-test.js"'
        response.attachment 'attachment.js'
        assert.equal response.type, 'application/javascript'
        assert.equal response.get('Content-Disposition'), 'attachment; filename="attachment.js"'
        yield return
  describe '#writable', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if response is writable', ->
      co ->
        KEY = 'TEST_RESPONSE_020'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        res.finished = yes
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res = writable: yes
        # context = { res }
        # context = { res }
        response = TestResponse.new context
        assert.isTrue response.writable
        yield return
  describe '#is', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check `Content-Type` header', ->
      co ->
        KEY = 'TEST_RESPONSE_021'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: {}
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        response.type = 'data.json'
        assert.equal response.is('html' , 'application/*'), 'application/json'
        assert.isFalse response.is 'html'
        yield return
  describe '#body', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response body', ->
      co ->
        KEY = 'TEST_RESPONSE_022'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: {}
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        assert.isUndefined response.body
        response.body = 'TEST'
        assert.equal response.status, 200
        assert.equal response.message, 'OK'
        assert.equal response.get('Content-Type'), 'text/plain; charset=utf-8'
        assert.equal response.length, 4
        response.body = null
        assert.equal response.status, 204
        assert.equal response.message, 'No Content'
        assert.equal response.get('Content-Type'), ''
        assert.equal response.length, 0
        response._explicitStatus = no
        response.body = new Buffer '7468697320697320612074c3a97374', 'hex'
        assert.equal response.status, 200
        assert.equal response.message, 'OK'
        assert.equal response.get('Content-Type'), 'application/octet-stream'
        assert.equal response.length, 15
        response.body = null
        response._explicitStatus = no
        response.body = '<html></html>'
        assert.equal response.status, 200
        assert.equal response.message, 'OK'
        assert.equal response.get('Content-Type'), 'text/html; charset=utf-8'
        assert.equal response.length, 13
        response.body = null
        response._explicitStatus = no
        response.body = { test: 'TEST' }
        assert.equal response.status, 200
        assert.equal response.message, 'OK'
        assert.equal response.get('Content-Type'), 'application/json; charset=utf-8'
        assert.equal response.length, 15
        yield return
  describe '#length', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get response data length', ->
      co ->
        KEY = 'TEST_RESPONSE_023'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: {}
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        assert.equal response.length, 0
        response.length = 10
        assert.equal response.length, 10
        response.remove 'Content-Length'
        response.body = '<html></html>'
        assert.equal response.length, 13
        response.remove 'Content-Length'
        response.body = new Buffer '7468697320697320612074c3a97374', 'hex'
        assert.equal response.length, 15
        response.remove 'Content-Length'
        response.body = test: 'TEST123'
        assert.equal response.length, 18
        yield return
  describe '#redirect', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should send redirect', ->
      co ->
        KEY = 'TEST_RESPONSE_024'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          type: (value) ->
            if arguments.length is 0
              @getHeader 'Content-Type'
            else
              type = (mimeTypes.lookup value) or value
              if type?
                @setHeader 'Content-Type', type
              else
                @removeHeader 'Content-Type'
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          redirect: (args...) ->
            switch args.length
              when 1
                [ url ] = args
              when 2
                [ code, url ] = args
              else
                throw new Error 'There is needed exactly one or two arguments'
            if code? and not @statusCode?
              @statusCode = code
              @statusMessage = status.codes[code]
            @setHeader 'Location', url
            @
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'accept': 'application/json, text/plain, image/png'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'accept': 'application/json, text/plain, image/png'
        # res =
        #   headers: {}
        #   type: (value) ->
        #     if arguments.length is 0
        #       @getHeader 'Content-Type'
        #     else
        #       type = (mimeTypes.lookup value) or value
        #       if type?
        #         @setHeader 'Content-Type', type
        #       else
        #         @removeHeader 'Content-Type'
        #   redirect: (args...) ->
        #     switch args.length
        #       when 1
        #         [ url ] = args
        #       when 2
        #         [ code, url ] = args
        #       else
        #         throw new Error 'There is needed exactly one or two arguments'
        #     if code? and not @statusCode?
        #       @statusCode = code
        #       @statusMessage = status.codes[code]
        #     @setHeader 'Location', url
        #     @
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()] ? ''
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = {
        #   switch: configs: trustProxy: yes
        #   res, req,
        #   get: (args...) -> request.get args...
        #   accepts: (args...) -> request.accepts args...
        #   accept: accepts req
        # }
        request = Test::Request.new context
        response = TestResponse.new context
        response.redirect 'back', 'http://localhost:8888/test1'
        assert.equal response.get('Location'), 'http://localhost:8888/test1'
        assert.equal response.status, 302
        assert.equal response.message, 'Found'
        req.headers.referrer = 'http://localhost:8888/test3'
        response.redirect 'back'
        assert.equal response.get('Location'), 'http://localhost:8888/test3'
        assert.equal response.status, 302
        assert.equal response.message, 'Found'
        response.redirect 'http://localhost:8888/test2'
        assert.equal response.get('Location'), 'http://localhost:8888/test2'
        assert.equal response.status, 302
        assert.equal response.message, 'Found'
        yield return
  describe '#flushHeaders', ->
    facade = null
    afterEach ->
      facade?.remove?()
    after ->
      console.log 'ArangoResponse TESTS END'
    it 'should clear all headers', ->
      co ->
        KEY = 'TEST_RESPONSE_025'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResponse extends Test::ArangoResponse
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @include Test::ArangoSwitchMixin
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          headers: {}
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = { res }
        response = TestResponse.new context
        now = new Date
        array = [ 1, now, 'TEST']
        response.set
          'Content-Type': 'text/plain'
          'Date': now
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
          'Test': array
        assert.equal response.get('Content-Type'), 'text/plain'
        assert.equal response.get('Date'), "#{now}"
        assert.equal response.get('Abc'), '123'
        assert.equal response.get('Last-Date'), "#{now}"
        assert.equal response.get('New-Test'), 'Test'
        assert.deepEqual response.get('Test'), [ '1', "#{now}", 'TEST']
        response.flushHeaders()
        assert.equal response.get('Content-Type'), ''
        assert.equal response.get('Date'), ''
        assert.equal response.get('Abc'), ''
        assert.equal response.get('Last-Date'), ''
        assert.equal response.get('New-Test'), ''
        assert.equal response.get('Test'), ''
        yield return
