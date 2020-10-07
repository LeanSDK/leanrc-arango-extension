{ expect, assert } = require 'chai'
LeanRC = require '@leansdk/leanrc'
ArangoExtension = require '../../..'
{ co } = LeanRC::Utils


describe 'ArangoConfigurationMixin', ->
  describe '#defineConfigProperties', ->
    after ->
      console.log 'ArangoConfigurationMixin TESTS END'
    it 'should define configuration properties', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @initialize()
        class TestConfiguration extends Test::Configuration
          @inheritProtected()
          @include Test::ArangoConfigurationMixin
          @module Test
          @initialize()
        config = TestConfiguration.new 'TEST_CONFIG'
        config.defineConfigProperties()
        assert.propertyVal config, 'test1', 'Test1'
        assert.propertyVal config, 'test2', 42.42
        assert.propertyVal config, 'test3', true
        assert.propertyVal config, 'test4', 42
        assert.deepPropertyVal config, 'test5', '{"test":"test"}'
        assert.propertyVal config, 'test6', 'testpassword'
        yield return
