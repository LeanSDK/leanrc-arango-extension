{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
accepts = require 'accepts'
LeanRC = require '@leansdk/leanrc'
EventEmitter = require 'events'
ArangoExtension = require '../../..'

{ co } = LeanRC::Utils


describe 'ArangoRequest', ->
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create Request instance', ->
      co ->
        KEY = 'TEST_REQUEST_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.instanceOf request, TestRequest
        assert.equal request.ctx, context
        assert.equal request.ip, '192.168.0.1'
        yield return
  describe '#req', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request native value', ->
      co ->
        KEY = 'TEST_REQUEST_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.req, context.req
        yield return
  describe '#switch', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get switch internal value', ->
      co ->
        KEY = 'TEST_REQUEST_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.switch, context.switch
        yield return
  describe '#headers', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get headers value', ->
      co ->
        KEY = 'TEST_REQUEST_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.headers, context.req.headers
        yield return
  describe '#header', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get header value', ->
      co ->
        KEY = 'TEST_REQUEST_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.header, context.req.headers
        yield return
  describe '#originalUrl', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get original URL', ->
      co ->
        KEY = 'TEST_REQUEST_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   originalUrl: 'http://localhost:8888'
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.originalUrl, context.originalUrl
        yield return
  describe '#url', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set and get native request URL', ->
      co ->
        KEY = 'TEST_REQUEST_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        request = TestRequest.new context
        assert.equal request.url, 'http://localhost:8888'
        request.url = 'http://localhost:9999'
        assert.equal request.url, 'http://localhost:9999'
        assert.equal context.req.url, 'http://localhost:9999'
        yield return
  describe '#socket', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request socket', ->
      co ->
        KEY = 'TEST_REQUEST_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
          socket: undefined
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch:
        #     configs:
        #       trustProxy: yes
        #   req:
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        #     # socket: {}
        request = TestRequest.new context
        assert.equal request.socket, context.req.socket
        yield return
  describe '#protocol', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request protocol name', ->
      co ->
        KEY = 'TEST_REQUEST_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          protocol: 'http'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.protocol, 'http'
        req =
          protocol: 'https'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
          socket: encrypted: yes
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.protocol, 'https'
        req =
          protocol: 'https'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: yes
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.protocol, 'https'
        req =
          protocol: 'https'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.protocol, 'https'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # context = Test::Context.new req, res, switchMediator
        # request = TestRequest.new
        #   switch: configs: trustProxy: no
        #   req:
        #     protocol: 'http'
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.equal request.protocol, 'http'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     protocol: 'https'
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.equal request.protocol, 'https'
        yield return
  describe '#get', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get single header', ->
      co ->
        KEY = 'TEST_REQUEST_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'referrer': 'localhost'
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
            'abc': 'def'
        context = Test::Context.new req, res, switchMediator
        # context =
        #   switch: configs: trustProxy: yes
        #   req:
        #     url: 'http://localhost:8888'
        #     headers:
        #       'referrer': 'localhost'
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-proto': 'https'
        #       'abc': 'def'
        request = TestRequest.new context
        assert.equal request.get('Referrer'), 'localhost'
        assert.equal request.get('X-Forwarded-For'), '192.168.0.1'
        assert.equal request.get('X-Forwarded-Proto'), 'https'
        assert.equal request.get('Abc'), 'def'
        assert.equal request.get('123'), ''
        yield return
  describe '#host', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get full host name with port', ->
      co ->
        KEY = 'TEST_REQUEST_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.host, 'localhost:9999'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost:8888, localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.host, 'localhost:8888'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.host, ''
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'host': 'localhost:9999'
        # assert.equal request.host, 'localhost:9999'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-host': 'localhost:8888, localhost:9999'
        # assert.equal request.host, 'localhost:8888'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.equal request.host, ''
        yield return
  describe '#origin', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request origin', ->
      co ->
        KEY = 'TEST_REQUEST_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          protocol: 'https'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
            'x-forwarded-host': 'localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     protocol: 'https'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-host': 'localhost:9999'
        assert.equal request.origin, 'https://localhost:9999'
        yield return
  describe '#href', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request hyper reference', ->
      co ->
        KEY = 'TEST_REQUEST_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          protocol: 'http'
          url: 'http://localhost:8888/test'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.href, 'http://localhost:8888/test'
        req =
          protocol: 'https'
          url: '/test'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
            'x-forwarded-host': 'localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.href, 'https://localhost:9999/test'
        # request = TestRequest.new
        #   originalUrl: 'http://localhost:8888/test'
        #   switch: configs: trustProxy: yes
        #   req:
        #     protocol: 'http'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.equal request.href, 'http://localhost:8888/test'
        # request = TestRequest.new
        #   originalUrl: '/test'
        #   switch: configs: trustProxy: yes
        #   req:
        #     protocol: 'https'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-host': 'localhost:9999'
        # assert.equal request.href, 'https://localhost:9999/test'
        yield return
  describe '#method', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request method', ->
      co ->
        KEY = 'TEST_REQUEST_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: '/test'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # req =
        #   method: 'POST'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # request = TestRequest.new
        #   originalUrl: '/test'
        #   switch: configs: trustProxy: yes
        #   req: req
        assert.equal request.method, 'POST'
        request.method = 'PUT'
        assert.equal request.method, 'PUT'
        assert.equal req.method, 'PUT'
        yield return
  describe '#path', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request path', ->
      co ->
        KEY = 'TEST_REQUEST_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # req =
        #   url: 'https://localhost:8888/test?t=ttt'
        #   method: 'POST'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req: req
        assert.equal request.path, '/test'
        request.path = '/test1'
        assert.equal request.path, '/test1'
        assert.equal req.url, 'https://localhost:8888/test1?t=ttt'
        yield return
  describe '#querystring', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set query string', ->
      co ->
        KEY = 'TEST_REQUEST_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # req =
        #   url: 'https://localhost:8888/test?t=ttt'
        #   method: 'POST'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req: req
        assert.equal request.querystring, 't=ttt'
        request.querystring = 'a=aaa'
        assert.equal request.querystring, 'a=aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#search', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set search string', ->
      co ->
        KEY = 'TEST_REQUEST_017'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # req =
        #   url: 'https://localhost:8888/test?t=ttt'
        #   method: 'POST'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req: req
        assert.equal request.search, '?t=ttt'
        request.search = 'a=aaa'
        assert.equal request.search, '?a=aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#query', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set query params', ->
      co ->
        KEY = 'TEST_REQUEST_018'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'https://localhost:8888/test?t=ttt'
          method: 'POST'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # req =
        #   url: 'https://localhost:8888/test?t=ttt'
        #   method: 'POST'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req: req
        assert.deepEqual request.query, t: 'ttt'
        request.query = a: 'aaa'
        assert.deepEqual request.query, a: 'aaa'
        assert.equal req.url, 'https://localhost:8888/test?a=aaa'
        yield return
  describe '#hostname', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get host name without port', ->
      co ->
        KEY = 'TEST_REQUEST_019'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.hostname, 'localhost'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost1:8888, localhost2:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.hostname, 'localhost1'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.equal request.hostname, ''
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'host': 'localhost:9999'
        # assert.equal request.hostname, 'localhost'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-host': 'localhost1:8888, localhost2:9999'
        # assert.equal request.hostname, 'localhost1'
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.equal request.hostname, ''
        yield return
  describe '#fresh', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test request freshness', ->
      co ->
        KEY = 'TEST_REQUEST_020'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        Reflect.defineProperty res, '_headers',
          writable: yes
          value: 'etag': '"bar"'
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = Test::Context.new req, res, switchMediator
        Reflect.defineProperty context, 'status',
          writable: yes
          value: 200
        request = TestRequest.new context
        assert.isFalse request.fresh
        Reflect.defineProperty res, '_headers',
          writable: yes
          value: 'etag': '"foo"'
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = Test::Context.new req, res, switchMediator
        Reflect.defineProperty context, 'status',
          writable: yes
          value: 200
        request = TestRequest.new context
        assert.isTrue request.fresh
        # request = TestRequest.new
        #   status: 200
        #   switch: configs: trustProxy: yes
        #   response:
        #     headers: 'etag': '"bar"'
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'if-none-match': '"foo"'
        # assert.isFalse request.fresh
        # request = TestRequest.new
        #   status: 200
        #   switch: configs: trustProxy: yes
        #   response:
        #     headers: 'etag': '"foo"'
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'if-none-match': '"foo"'
        # assert.isTrue request.fresh
        yield return
  describe '#stale', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test inverted request freshness', ->
      co ->
        KEY = 'TEST_REQUEST_021'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        Reflect.defineProperty res, '_headers',
          writable: yes
          value: 'etag': '"bar"'
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = Test::Context.new req, res, switchMediator
        Reflect.defineProperty context, 'status',
          writable: yes
          value: 200
        request = TestRequest.new context
        assert.isTrue request.stale
        Reflect.defineProperty res, '_headers',
          writable: yes
          value: 'etag': '"foo"'
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        context = Test::Context.new req, res, switchMediator
        Reflect.defineProperty context, 'status',
          writable: yes
          value: 200
        request = TestRequest.new context
        assert.isFalse request.stale
        # request = TestRequest.new
        #   status: 200
        #   switch: configs: trustProxy: yes
        #   response:
        #     headers: 'etag': '"bar"'
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'if-none-match': '"foo"'
        # assert.isTrue request.stale
        # request = TestRequest.new
        #   status: 200
        #   switch: configs: trustProxy: yes
        #   response:
        #     headers: 'etag': '"foo"'
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'if-none-match': '"foo"'
        # assert.isFalse request.stale
        yield return
  describe '#idempotent', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test if method is idempotent', ->
      co ->
        KEY = 'TEST_REQUEST_022'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.isTrue request.idempotent
        req =
          url: 'http://localhost:8888'
          method: 'POST'
          headers:
            'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.isFalse request.idempotent
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        # assert.isTrue request.idempotent
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     method: 'POST'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        # assert.isFalse request.idempotent
        yield return
  describe '#charset', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get charset of request', ->
      co ->
        KEY = 'TEST_REQUEST_023'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'image/svg+xml; charset=utf-8'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'content-type': 'image/svg+xml; charset=utf-8'
        assert.equal request.charset, 'utf-8'
        yield return
  describe '#length', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get content length of request', ->
      co ->
        KEY = 'TEST_REQUEST_024'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          method: 'GET'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-length': '123456'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     method: 'GET'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'content-length': '123456'
        assert.equal request.length, 123456
        yield return
  describe '#secure', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should if request protocol is secure', ->
      co ->
        KEY = 'TEST_REQUEST_025'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          secure: no
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.isFalse request.secure
        req =
          secure: yes
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.isTrue request.secure
        # request = TestRequest.new
        #   switch: configs: trustProxy: no
        #   req:
        #     secure: no
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1'
        # assert.isFalse request.secure
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     secure: yes
        #     url: 'http://localhost:8888'
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'x-forwarded-proto': 'https'
        # assert.isTrue request.secure
        yield return
  describe '#ips', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request IPs', ->
      co ->
        KEY = 'TEST_REQUEST_026'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        # request = TestRequest.new
        #   switch: configs: trustProxy: yes
        #   req:
        #     url: 'http://localhost:8888'
        #     headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        assert.deepEqual request.ips, [ '192.168.0.1', '192.168.1.1', '123.222.12.21' ]
        yield return
  describe '#subdomains', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request URL subdomains', ->
      co ->
        KEY = 'TEST_REQUEST_027'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'www.test.localhost:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.deepEqual request.subdomains, [ 'test', 'www' ]
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': '192.168.0.2:9999'
        context = Test::Context.new req, res, switchMediator
        request = TestRequest.new context
        assert.deepEqual request.subdomains, []
        # request = TestRequest.new
        #   switch: configs:
        #     trustProxy: yes
        #     subdomainOffset: 1
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'host': 'www.test.localhost:9999'
        # assert.deepEqual request.subdomains, [ 'test', 'www' ]
        # request = TestRequest.new
        #   switch: configs:
        #     trustProxy: yes
        #     subdomainOffset: 1
        #   req:
        #     headers:
        #       'x-forwarded-for': '192.168.0.1'
        #       'host': '192.168.0.2:9999'
        # assert.deepEqual request.subdomains, []
        yield return
  describe '#accepts', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable types from request', ->
      co ->
        KEY = 'TEST_REQUEST_028'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          accepts: -> @headers['accept'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept': 'application/json, text/plain, image/png'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        #   accept: accepts req
        request = TestRequest.new context
        assert.deepEqual request.accepts(), [
          'application/json', 'text/plain', 'image/png'
        ]
        yield return
  describe '#acceptsCharsets', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable charsets from request', ->
      co ->
        KEY = 'TEST_REQUEST_029'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
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
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        #   accept: accepts req
        request = TestRequest.new context
        assert.deepEqual request.acceptsCharsets(), [
          'utf-8', 'iso-8859-1', '*'
        ]
        yield return
  describe '#acceptsEncodings', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable encodings from request', ->
      co ->
        KEY = 'TEST_REQUEST_030'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          acceptsEncodings: -> @headers['accept-encoding'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        #   accept: accepts req
        request = TestRequest.new context
        assert.deepEqual request.acceptsEncodings(), [
          'compress', 'gzip', 'deflate', 'sdch', 'identity'
        ]
        yield return
  describe '#acceptsLanguages', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable languages from request', ->
      co ->
        KEY = 'TEST_REQUEST_031'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          acceptsLanguages: -> @headers['accept-language'].split /\s*\,\s*/
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-language': 'en, ru, cn, fr'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-language': 'en, ru, cn, fr'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        #   accept: accepts req
        request = TestRequest.new context
        assert.deepEqual request.acceptsLanguages(), [
          'en', 'ru', 'cn', 'fr'
        ]
        yield return
  describe '#type', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get types from request', ->
      co ->
        KEY = 'TEST_REQUEST_032'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'application/json'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'content-type': 'application/json'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        request = TestRequest.new context
        assert.equal request.type, 'application/json'
        yield return
  describe '#is', ->
    facade = null
    afterEach ->
      facade?.remove?()
    after ->
      console.log 'ArangoRequest TESTS END'
    it 'should test types from request', ->
      co ->
        KEY = 'TEST_REQUEST_033'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/../mixins/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRequest extends Test::ArangoRequest
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
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          is: -> 'application/json'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'application/json'
            'content-length': '0'
        context = Test::Context.new req, res, switchMediator
        # req =
        #   is: -> 'application/json'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'content-type': 'application/json'
        #     'content-length': '0'
        # context =
        #   switch: configs: trustProxy: yes
        #   req: req
        request = TestRequest.new context
        assert.equal request.is('html' , 'application/*'), 'application/json'
        yield return
