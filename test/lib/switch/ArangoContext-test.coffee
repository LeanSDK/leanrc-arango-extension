{ Readable } = require 'stream'
EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
# accepts = require 'accepts'
mimeTypes = require 'mime-types'
contentDisposition = require 'content-disposition'
status = require 'statuses'
httpErrors = require 'http-errors'
EventEmitter = require 'events'
LeanRC = require '@leansdk/leanrc'

ArangoExtension = require '../../..'

{ co } = LeanRC::Utils


describe 'ArangoContext', ->
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create ArangoContext instance', ->
      co ->
        KEY = 'TEST_CONTEXT_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = Test::ArangoContext.new req, res, switchInstance
        assert.instanceOf context, TestContext
        assert.equal context.req, req
        assert.equal context.res, res
        assert.equal context.switch, switchMediator
        assert.instanceOf context.request, Test::ArangoRequest
        assert.instanceOf context.response, Test::ArangoResponse
        assert.instanceOf context.cookies, Test::Cookies
        assert.deepEqual context.state, {}
        yield return
  describe '#throw', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should throw an error exception', ->
      co ->
        KEY = 'TEST_CONTEXT_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.throws -> context.throw 404
        , httpErrors.HttpError
        assert.throws -> context.throw 501, 'Not Implemented'
        , httpErrors.HttpError
        yield return
  describe '#assert', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should assert with status codes', ->
      co ->
        KEY = 'TEST_CONTEXT_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.doesNotThrow -> context.assert yes
        assert.throws -> context.assert 'test' is 'TEST', 500, 'Internal Error'
        , Error
        yield return
  describe '#header', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request header', ->
      co ->
        KEY = 'TEST_CONTEXT_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.header, req.headers
        yield return
  describe '#headers', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request headers', ->
      co ->
        KEY = 'TEST_CONTEXT_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.headers, req.headers
        yield return
  describe '#method', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request method', ->
      co ->
        KEY = 'TEST_CONTEXT_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.method, 'POST'
        context.method = 'PUT'
        assert.equal context.method, 'PUT'
        assert.equal req.method, 'PUT'
        yield return
  describe '#url', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request URL', ->
      co ->
        KEY = 'TEST_CONTEXT_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.url, 'http://localhost:8888/test1'
        context.url = 'http://localhost:8888/test2'
        assert.equal context.url, 'http://localhost:8888/test2'
        assert.equal req.url, 'http://localhost:8888/test2'
        yield return
  describe '#originalUrl', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get original request URL', ->
      co ->
        KEY = 'TEST_CONTEXT_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.originalUrl, 'http://localhost:8888/test1'
        yield return
  describe '#origin', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request origin data', ->
      co ->
        KEY = 'TEST_CONTEXT_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          protocol: 'http'
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   protocol: 'http'
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:8888'
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.origin, 'http://localhost:8888'
        req.protocol = 'https'
        assert.equal context.origin, 'https://localhost:8888'
        yield return
  describe '#href', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request hyper reference', ->
      co ->
        KEY = 'TEST_CONTEXT_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          protocol: 'http'
          method: 'POST'
          url: '/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   protocol: 'http'
        #   method: 'POST'
        #   url: '/test1'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:8888'
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.href, 'http://localhost:8888/test1'
        req.url = 'http://localhost1:9999/test2'
        context = TestContext.new req, res, switchMediator
        assert.equal context.href, 'http://localhost1:9999/test2'
        yield return
  describe '#path', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request path', ->
      co ->
        KEY = 'TEST_CONTEXT_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.path, '/test1'
        context.path = '/test2'
        assert.equal context.path, '/test2'
        assert.equal req.url, 'http://localhost:8888/test2?t=ttt'
        yield return
  describe '#query', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request query object', ->
      co ->
        KEY = 'TEST_CONTEXT_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.query, t: 'ttt'
        context.query = a: 'aaa'
        assert.deepEqual context.query, a: 'aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#querystring', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request query string', ->
      co ->
        KEY = 'TEST_CONTEXT_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.querystring, 't=ttt'
        context.querystring = 'a=aaa'
        assert.equal context.querystring, 'a=aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#host', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request host', ->
      co ->
        KEY = 'TEST_CONTEXT_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:9999'
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.host, 'localhost:9999'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost:8888, localhost:9999'
        context = TestContext.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'x-forwarded-host': 'localhost:8888, localhost:9999'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.host, 'localhost:8888'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # req =
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.host, ''
        yield return
  describe '#hostname', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request host name', ->
      co ->
        KEY = 'TEST_CONTEXT_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:9999'
        # res =
        #   headers: 'Foo': 'Bar'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.hostname, 'localhost'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost1:8888, localhost:9999'
        context = TestContext.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'x-forwarded-host': 'localhost1:8888, localhost:9999'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.hostname, 'localhost1'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # req =
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.hostname, ''
        yield return
  describe '#fresh', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test request freshness', ->
      co ->
        KEY = 'TEST_CONTEXT_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   headers: 'etag': '"bar"'
        # context = TestContext.new req, res, switchInstance
        context.status = 200
        assert.isFalse context.fresh
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res.headers = 'etag': '"foo"'
        context = TestContext.new req, res, switchMediator
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   headers: 'etag': '"foo"'
        # context = TestContext.new req, res, switchInstance
        context.status = 200
        assert.isTrue context.fresh
        yield return
  describe '#stale', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test request non-freshness', ->
      co ->
        KEY = 'TEST_CONTEXT_017'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   headers: 'etag': '"bar"'
        # context = TestContext.new req, res, switchInstance
        context.status = 200
        assert.isTrue context.stale
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res.headers = 'etag': '"foo"'
        context = TestContext.new req, res, switchMediator
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   headers: 'etag': '"foo"'
        # context = TestContext.new req, res, switchInstance
        context.status = 200
        assert.isFalse context.stale
        yield return
  describe '#socket', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request socket', ->
      co ->
        KEY = 'TEST_CONTEXT_018'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          # socket: {}
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.equal context.socket, req.socket
        yield return
  describe '#protocol', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request protocol', ->
      co ->
        KEY = 'TEST_CONTEXT_019'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          protocol: 'http'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        Reflect.defineProperty switchMediator, 'configs',
          writable: yes
          value: trustProxy: no
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: no
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   protocol: 'http'
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.equal context.protocol, 'http'
        req.protocol = 'https'
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'https'
        yield return
  describe '#secure', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if request secure', ->
      co ->
        KEY = 'TEST_CONTEXT_020'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          secure: no
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: no
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   secure: no
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.isFalse context.secure
        req.secure = yes
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.secure
        yield return
  describe '#ips', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request IPs', ->
      co ->
        KEY = 'TEST_CONTEXT_021'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers:
            'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.ips, [ '192.168.0.1', '192.168.1.1', '123.222.12.21' ]
        yield return
  describe '#ip', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request IP', ->
      co ->
        KEY = 'TEST_CONTEXT_022'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.ip, '192.168.0.1'
        yield return
  describe '#subdomains', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request subdomains', ->
      co ->
        KEY = 'TEST_CONTEXT_023'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'www.test.localhost:9999'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        #     subdomainOffset: 1
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'www.test.localhost:9999'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.subdomains, [ 'test', 'www' ]
        req.headers.host = '192.168.0.2:9999'
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.subdomains, []
        yield return
  describe '#is', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test types from request', ->
      co ->
        KEY = 'TEST_CONTEXT_024'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          is: -> 'application/json'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'application/json'
            'content-length': '0'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   is: -> 'application/json'
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'content-type': 'application/json'
        #     'content-length': '0'
        # res =
        #   headers: 'etag': '"bar"'
        # context = TestContext.new req, res, switchInstance
        assert.equal context.is('html' , 'application/*'), 'application/json'
        yield return
  describe '#accepts', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable types from request', ->
      co ->
        KEY = 'TEST_CONTEXT_025'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          accepts: -> @headers['accept'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   accepts: -> @headers['accept'].split /\s*\,\s*/
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept': 'application/json, text/plain, image/png'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.accepts(), [
          'application/json', 'text/plain', 'image/png'
        ]
        yield return
  describe '#acceptsEncodings', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable encodings from request', ->
      co ->
        KEY = 'TEST_CONTEXT_026'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          acceptsEncodings: -> @headers['accept-encoding'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   acceptsEncodings: -> @headers['accept-encoding'].split /\s*\,\s*/
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.acceptsEncodings(), [
          'compress', 'gzip', 'deflate', 'sdch', 'identity'
        ]
        yield return
  describe '#acceptsCharsets', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable charsets from request', ->
      co ->
        KEY = 'TEST_CONTEXT_027'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          acceptsCharsets: ->
            @headers['accept-charset'].split /\s*\,\s*/
              .map (charset) ->
                data = charset.split ';'
                data[1] = if data[1]? then +data[1].split('=')[1] else 1
                data
              .sort (a, b) ->
                return 0  if a[1] is b[1]
                return if a[1] > b[1] then -1 else 1
              .map (item) -> item[0]
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   acceptsCharsets: ->
        #     @headers['accept-charset'].split /\s*\,\s*/
        #       .map (charset) ->
        #         data = charset.split ';'
        #         data[1] = if data[1]? then +data[1].split('=')[1] else 1
        #         data
        #       .sort (a, b) ->
        #         return 0  if a[1] is b[1]
        #         return if a[1] > b[1] then -1 else 1
        #       .map (item) -> item[0]
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.acceptsCharsets(), [
          'utf-8', 'iso-8859-1', '*'
        ]
        yield return
  describe '#acceptsLanguages', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable languages from request', ->
      co ->
        KEY = 'TEST_CONTEXT_028'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          acceptsLanguages: -> @headers['accept-language'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-language': 'en, ru, cn, fr'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   acceptsLanguages: -> @headers['accept-language'].split /\s*\,\s*/
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-language': 'en, ru, cn, fr'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.deepEqual context.acceptsLanguages(), [
          'en', 'ru', 'cn', 'fr'
        ]
        yield return
  describe '#get', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get single header from request', ->
      co ->
        KEY = 'TEST_CONTEXT_029'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          headers:
            'referrer': 'localhost'
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
            'abc': 'def'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'referrer': 'localhost'
        #     'x-forwarded-for': '192.168.0.1'
        #     'x-forwarded-proto': 'https'
        #     'abc': 'def'
        # res = headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.equal context.get('Referrer'), 'localhost'
        assert.equal context.get('X-Forwarded-For'), '192.168.0.1'
        assert.equal context.get('X-Forwarded-Proto'), 'https'
        assert.equal context.get('Abc'), 'def'
        assert.equal context.get('123'), ''
        yield return
  describe '#body', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response body', ->
      co ->
        KEY = 'TEST_CONTEXT_030'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          getHeaders: -> LeanRC::Utils.copy @headers
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
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
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        assert.isUndefined context.body
        context.body = 'TEST'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'text/plain; charset=utf-8'
        assert.equal context.response.length, '4'
        context.body = null
        assert.equal context.status, 204
        assert.equal context.message, 'No Content'
        assert.equal context.response.get('Content-Type'), ''
        assert.equal context.response.length, 0
        context.response._explicitStatus = no
        context.body = new Buffer '7468697320697320612074c3a97374', 'hex'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'application/octet-stream'
        assert.equal context.response.length, '15'
        context.body = null
        context.response._explicitStatus = no
        context.body = '<html></html>'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'text/html; charset=utf-8'
        assert.equal context.response.length, '13'
        context.body = null
        context.response._explicitStatus = no
        context.body = { test: 'TEST' }
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'application/json; charset=utf-8'
        assert.equal context.response.length, '15'
        yield return
  describe '#status', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response status', ->
      co ->
        KEY = 'TEST_CONTEXT_031'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        assert.equal context.status, 200
        context.status = 400
        assert.equal context.status, 400
        assert.equal res.statusCode, 400
        assert.throws -> context.status = 'TEST'
        assert.throws -> context.status = 0
        assert.doesNotThrow -> context.status = 200
        yield return
  describe '#message', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response message', ->
      co ->
        KEY = 'TEST_CONTEXT_032'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        assert.equal context.message, 'OK'
        context.message = 'TEST'
        assert.equal context.message, 'TEST'
        assert.equal res.statusMessage, 'TEST'
        yield return
  describe '#length', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response body length', ->
      co ->
        KEY = 'TEST_CONTEXT_033'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
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
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        assert.equal context.length, 0
        context.length = 10
        assert.equal context.length, 10
        context.response.remove 'Content-Length'
        context.body = '<html></html>'
        assert.equal context.length, 13
        context.response.remove 'Content-Length'
        context.body = new Buffer '7468697320697320612074c3a97374', 'hex'
        assert.equal context.length, 15
        context.response.remove 'Content-Length'
        context.body = test: 'TEST123'
        assert.equal context.length, 18
        yield return
  describe '#writable', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if response is writable', ->
      co ->
        KEY = 'TEST_CONTEXT_034'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   writable: yes
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        assert.isTrue context.writable
        yield return
  describe '#type', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get, set and remove `Content-Type` header', ->
      co ->
        KEY = 'TEST_CONTEXT_035'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
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
        # context = TestContext.new req, res, switchInstance
        assert.equal context.type, ''
        context.type = 'markdown'
        assert.equal context.type, 'text/markdown'
        assert.equal res.headers['content-type'], 'text/markdown; charset=utf-8'
        context.type = 'file.json'
        assert.equal context.type, 'application/json'
        assert.equal res.headers['content-type'], 'application/json; charset=utf-8'
        context.type = 'text/html'
        assert.equal context.type, 'text/html'
        assert.equal res.headers['content-type'], 'text/html; charset=utf-8'
        context.type = null
        assert.equal context.type, ''
        assert.isUndefined res.headers['content-type']
        yield return
  describe '#headerSent', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get res.headersSent value', ->
      co ->
        KEY = 'TEST_CONTEXT_036'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headersSent: no
        #   headers: {}
        # context = TestContext.new req, res, switchInstance
        assert.equal context.headerSent, res.headersSent
        yield return
  describe '#redirect', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should send redirect', ->
      co ->
        KEY = 'TEST_CONTEXT_037'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept': 'application/json, text/plain, image/png'
        # res =
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
        # context = TestContext.new req, res, switchInstance
        context.redirect 'back', 'http://localhost:8888/test1'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test1'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        req.headers.referrer = 'http://localhost:8888/test3'
        context.redirect 'back'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test3'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        context.redirect 'http://localhost:8888/test2'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test2'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        yield return
  describe '#attachment', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should setup attachment', ->
      co ->
        KEY = 'TEST_CONTEXT_038'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
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
        # context = TestContext.new req, res, switchInstance
        context.attachment "#{__dirname}/#{__filename}"
        assert.equal context.type, 'application/javascript'
        assert.equal context.response.get('Content-Disposition'), 'attachment; filename="ArangoContext-test.js"'
        context.attachment 'attachment.js'
        assert.equal context.type, 'application/javascript'
        assert.equal context.response.get('Content-Disposition'), 'attachment; filename="attachment.js"'
        yield return
  describe '#set', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set specified response header', ->
      co ->
        KEY = 'TEST_CONTEXT_039'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        context.set 'Content-Type', 'text/plain'
        assert.equal res.headers['content-type'], 'text/plain'
        assert.equal context.response.get('Content-Type'), 'text/plain'
        now = new Date
        context.set 'Date', now
        assert.equal context.response.get('Date'), "#{now}"
        array = [ 1, now, 'TEST']
        context.set 'Test', array
        assert.deepEqual context.response.get('Test'), [ '1', "#{now}", 'TEST']
        context.set
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
        assert.equal context.response.get('Abc'), '123'
        assert.equal context.response.get('Last-Date'), "#{now}"
        assert.equal context.response.get('New-Test'), 'Test'
        yield return
  describe '#append', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should add specified response header value', ->
      co ->
        KEY = 'TEST_CONTEXT_040'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        context.append 'Test', 'data'
        assert.equal context.response.get('Test'), 'data'
        context.append 'Test', 'Test'
        assert.deepEqual context.response.get('Test'), [ 'data', 'Test' ]
        context.append 'Test', 'Test'
        assert.deepEqual context.response.get('Test'), [ 'data', 'Test', 'Test' ]
        yield return
  describe '#vary', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `Vary` header', ->
      co ->
        KEY = 'TEST_CONTEXT_041'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   vary: (value) -> @setHeader 'Vary', value
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        context.vary 'Origin'
        assert.equal context.response.get('Vary'), 'Origin'
        yield return
  describe '#flushHeaders', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should clear all headers', ->
      co ->
        KEY = 'TEST_CONTEXT_042'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        now = new Date
        array = [ 1, now, 'TEST']
        context.set
          'Content-Type': 'text/plain'
          'Date': now
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
          'Test': array
        assert.equal context.response.get('Content-Type'), 'text/plain'
        assert.equal context.response.get('Date'), "#{now}"
        assert.equal context.response.get('Abc'), '123'
        assert.equal context.response.get('Last-Date'), "#{now}"
        assert.equal context.response.get('New-Test'), 'Test'
        assert.deepEqual context.response.get('Test'), [ '1', "#{now}", 'TEST']
        context.flushHeaders()
        assert.equal context.response.get('Content-Type'), ''
        assert.equal context.response.get('Date'), ''
        assert.equal context.response.get('Abc'), ''
        assert.equal context.response.get('Last-Date'), ''
        assert.equal context.response.get('New-Test'), ''
        assert.equal context.response.get('Test'), ''
        yield return
  describe '#remove', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove specified response header', ->
      co ->
        KEY = 'TEST_CONTEXT_043'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        context.set 'Test', 'data'
        assert.equal context.response.get('Test'), 'data'
        context.remove 'Test'
        assert.equal context.response.get('Test'), ''
        yield return
  describe '#lastModified', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `Last-Modified` header', ->
      co ->
        KEY = 'TEST_CONTEXT_044'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        now = new Date
        context.lastModified = now
        assert.equal res.headers['last-modified'], now.toUTCString()
        assert.deepEqual context.response.lastModified, new Date now.toUTCString()
        yield return
  describe '#etag', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `ETag` header', ->
      co ->
        KEY = 'TEST_CONTEXT_045'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        # context = TestContext.new req, res, switchInstance
        etag = '123456789'
        context.etag = etag
        assert.equal res.headers['etag'], "\"#{etag}\""
        assert.deepEqual context.response.etag, "\"#{etag}\""
        etag = 'W/"123456789"'
        context.etag = etag
        assert.equal res.headers['etag'], etag
        assert.deepEqual context.response.etag, etag
        yield return
  describe '#onerror', ->
    facade = null
    afterEach ->
      facade?.remove?()
    after ->
      console.log 'ArangoContext TESTS END'
    it 'should run error handler', ->
      co ->
        KEY = 'TEST_CONTEXT_046'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends Test::ArangoContext
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
          status: (code) -> @statusCode = code
          type: (value) ->
            if arguments.length is 0
              @getHeader 'Content-Type'
            else
              type = (mimeTypes.lookup value) or value
              if type?
                @setHeader 'Content-Type', type
              else
                @removeHeader 'Content-Type'
          set: (headers) ->
            for headerName, headerValue of headers ? {}
              @setHeader headerName, headerValue
          getHeaders: -> LeanRC::Utils.copy @headers
          getHeader: (field) -> @headers[field.toLowerCase()]
          setHeader: (field, value) -> @headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @headers[field.toLowerCase()]
          send: (args...) -> @end args...
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            trigger.emit 'end', data
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @headers } = finished: no, headers: {'foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        Reflect.defineProperty switchMediator, 'getViewComponent',
          value: -> trigger
        context = TestContext.new req, res, switchMediator
        # switchInstance =
        #   getViewComponent: -> trigger
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
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
        #   status: (code) -> @statusCode = code
        #   set: (headers) ->
        #     for headerName, headerValue of headers ? {}
        #       @setHeader headerName, headerValue
        #   getHeaders: -> LeanRC::Utils.copy @headers
        #   getHeader: (field) -> @headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @headers[field.toLowerCase()]
        #   end: (data) -> trigger.emit 'end', data
        #   send: (args...) -> @end args...
        # context = TestContext.new req, res, switchInstance
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', (d)->
            console.log '>??? errorPromise d', d
            resolve d
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', (d)->
            console.log '>??? endPromise d', d
            resolve d
        try
          context.onerror 'TEST_ERROR'
        catch err
          console.log '???????>>>>>> err', err, err.stack
        console.log '???????>>>>>> onerror 111'
        try
          err = yield errorPromise
          data = yield endPromise
        catch err
          console.log '???????>>>>>>  222 err', err, err.stack
        console.log '???????>>>>>> onerror 222'

        assert.instanceOf err, Error
        assert.equal err.message, 'non-error thrown: TEST_ERROR'
        assert.equal err.status, 500
        console.log 'HHHHHHHHHHHHHHHHHHHHHH', data
        assert.propertyVal data, 'error', yes
        assert.propertyVal data, 'errorNum', 500
        assert.propertyVal data, 'errorMessage', 'Internal Server Error'
        assert.propertyVal data, 'code', 'Internal Server Error'
        # assert.deepEqual data,
        #   error: yes
        #   errorNum: 500
        #   errorMessage: 'Internal Server Error'
        #   code: 'Internal Server Error'
        console.log '???????>>>>>> onerror 333'
        context = TestContext.new req, res, switchMediator
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', resolve
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        console.log '???????>>>>>> onerror 444'
        context.onerror new Error 'TEST_ERROR'
        console.log '???????>>>>>> onerror 555'
        err = yield errorPromise
        data = yield endPromise
        console.log '???????>>>>>> onerror 666'
        assert.instanceOf err, Error
        assert.equal err.message, 'TEST_ERROR'
        assert.equal err.status, 500
        console.log 'FFFFFFFFFFFFFFFFFFF', data
        assert.propertyVal data, 'error', yes
        assert.propertyVal data, 'errorNum', 500
        assert.propertyVal data, 'errorMessage', 'Internal Server Error'
        assert.propertyVal data, 'code', 'Internal Server Error'
        # assert.deepEqual data,
        #   error: yes
        #   errorNum: 500
        #   errorMessage: 'Internal Server Error'
        #   code: 'Internal Server Error'
        console.log '???????>>>>>> onerror 777'
        context = TestContext.new req, res, switchMediator
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', resolve
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        console.log '???????>>>>>> onerror 888'
        context.onerror httpErrors 400, 'TEST_ERROR'
        console.log '???????>>>>>> onerror 999'
        err = yield errorPromise
        data = yield endPromise
        console.log '???????>>>>>> onerror 000'
        assert.instanceOf err, httpErrors.BadRequest
        assert.isTrue err.expose
        assert.equal err.message, 'TEST_ERROR'
        assert.equal err.status, 400
        console.log 'EEEEEEEEEEEEEEEEEE', data
        assert.propertyVal data, 'error', yes
        assert.propertyVal data, 'errorNum', 400
        assert.propertyVal data, 'errorMessage', 'TEST_ERROR'
        assert.propertyVal data, 'code', 'Bad Request'
        # assert.deepEqual data,
        #   error: yes
        #   errorNum: 400
        #   errorMessage: 'TEST_ERROR'
        #   code: 'Bad Request'
        yield return
