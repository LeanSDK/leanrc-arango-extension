{ db }  = require '@arangodb'
qb      = require 'aqb'

{ expect, assert }  = require 'chai'
sinon               = require 'sinon'
_                   = require 'lodash'
moment              = require 'moment'

LeanRC              = require '@leansdk/leanrc'

ArangoExtension = require '../../..'
{ co }          = LeanRC::Utils

###
commonServerInitializer = require.main.require 'test/common/server'
server = commonServerInitializer fixture: 'ArangoCollectionMixin'
###

ARANGODB_DUPLICATE_NAME = 1207

PREFIX = module.context.collectionPrefix

COL_NAME = "#{PREFIX}samples"

describe 'ArangoCollectionMixin', ->
  before ->
    if (db._collection COL_NAME)?
      db._drop COL_NAME
    collection = db._create COL_NAME
    date = new Date()
    collection.save id: 1, data: 'three', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 2, data: 'men', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 3, data: 'in', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 4, data: 'a boat', createdAt: date, updatedAt: date
  after ->
    try db._drop COL_NAME
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create ArangoDB collection instance', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          #
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        yield return
  describe '#operatorsMap', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get full operators map', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        { operatorsMap } = collection

        assert.isFunction operatorsMap['$and']
        assert.isFunction operatorsMap['$or']
        assert.isFunction operatorsMap['$not']
        assert.isFunction operatorsMap['$nor']

        assert.isFunction operatorsMap['$where']

        assert.isFunction operatorsMap['$eq']
        assert.isFunction operatorsMap['$ne']
        assert.isFunction operatorsMap['$lt']
        assert.isFunction operatorsMap['$lte']
        assert.isFunction operatorsMap['$gt']
        assert.isFunction operatorsMap['$gte']
        assert.isFunction operatorsMap['$in']
        assert.isFunction operatorsMap['$nin']

        assert.isFunction operatorsMap['$all']
        assert.isFunction operatorsMap['$elemMatch']
        assert.isFunction operatorsMap['$size']

        assert.isFunction operatorsMap['$exists']
        assert.isFunction operatorsMap['$type']

        assert.isFunction operatorsMap['$mod']
        assert.isFunction operatorsMap['$regex']

        assert.isFunction operatorsMap['$td']
        assert.isFunction operatorsMap['$ld']
        assert.isFunction operatorsMap['$tw']
        assert.isFunction operatorsMap['$lw']
        assert.isFunction operatorsMap['$tm']
        assert.isFunction operatorsMap['$lm']
        assert.isFunction operatorsMap['$ty']
        assert.isFunction operatorsMap['$ly']

        logicalOperator = operatorsMap['$and'] ['a', 'b', 'c']
        assert.deepEqual logicalOperator, qb.and 'a', 'b', 'c'
        logicalOperator = operatorsMap['$or'] ['a', 'b', 'c']
        assert.deepEqual logicalOperator, qb.or 'a', 'b', 'c'
        logicalOperator = operatorsMap['$not'] ['a', 'b', 'c']
        assert.deepEqual logicalOperator, qb.not 'a', 'b', 'c'
        logicalOperator = operatorsMap['$nor'] ['a', 'b', 'c']
        assert.deepEqual logicalOperator, qb.not qb.or 'a', 'b', 'c'

        assert.throws -> operatorsMap['$where'] ['a', 'b', 'c']
        , Error

        compOperator = operatorsMap['$eq'] 'a', 'b'
        assert.deepEqual compOperator, qb.eq qb('a'), qb('b')
        compOperator = operatorsMap['$eq'] 'a', '@b'
        assert.deepEqual compOperator, qb.eq qb('a'), qb.ref('b')
        compOperator = operatorsMap['$ne'] 'a', 'b'
        assert.deepEqual compOperator, qb.neq qb('a'), qb('b')
        compOperator = operatorsMap['$ne'] 'a', '@b'
        assert.deepEqual compOperator, qb.neq qb('a'), qb.ref('b')
        compOperator = operatorsMap['$lt'] 'a', 'b'
        assert.deepEqual compOperator, qb.lt qb('a'), qb('b')
        compOperator = operatorsMap['$lt'] 'a', '@b'
        assert.deepEqual compOperator, qb.lt qb('a'), qb.ref('b')
        compOperator = operatorsMap['$lte'] 'a', 'b'
        assert.deepEqual compOperator, qb.lte qb('a'), qb('b')
        compOperator = operatorsMap['$lte'] 'a', '@b'
        assert.deepEqual compOperator, qb.lte qb('a'), qb.ref('b')
        compOperator = operatorsMap['$gt'] 'a', 'b'
        assert.deepEqual compOperator, qb.gt qb('a'), qb('b')
        compOperator = operatorsMap['$gt'] 'a', '@b'
        assert.deepEqual compOperator, qb.gt qb('a'), qb.ref('b')
        compOperator = operatorsMap['$gte'] 'a', 'b'
        assert.deepEqual compOperator, qb.gte qb('a'), qb('b')
        compOperator = operatorsMap['$gte'] 'a', '@b'
        assert.deepEqual compOperator, qb.gte qb('a'), qb.ref('b')
        compOperator = operatorsMap['$in'] 'a', 'b'
        assert.deepEqual compOperator, qb.in qb('a'), qb('b')
        compOperator = operatorsMap['$in'] '@a', 'b'
        assert.deepEqual compOperator, qb.in qb.ref('a'), qb('b')
        compOperator = operatorsMap['$nin'] 'a', 'b'
        assert.deepEqual compOperator, qb.notIn qb('a'), qb('b')
        compOperator = operatorsMap['$nin'] '@a', 'b'
        assert.deepEqual compOperator, qb.notIn qb.ref('a'), qb('b')

        queryOperator = operatorsMap['$all'] 'a', ['b', 'c', 'd']
        assert.deepEqual queryOperator, qb.and [
          qb.in qb('b'), qb('a')
          qb.in qb('c'), qb('a')
          qb.in qb('d'), qb('a')
        ]...
        queryOperator = operatorsMap['$elemMatch'] '@a', ['b', 'c', 'd']
        assert.deepEqual queryOperator
        , qb.gt qb.expr('LENGTH(a[* FILTER b && c && d])'), qb 0
        queryOperator = operatorsMap['$size'] '@a', 'b'
        assert.deepEqual queryOperator, qb.eq qb.expr('LENGTH(a)'), qb('b')
        queryOperator = operatorsMap['$size'] '@a', '@b'
        assert.deepEqual queryOperator, qb.eq qb.expr('LENGTH(a)'), qb.ref('b')

        queryOperator = operatorsMap['$exists'] '@a', 'b'
        assert.deepEqual queryOperator, qb.eq qb.expr('HAS(a)'), qb('b')
        queryOperator = operatorsMap['$exists'] '@a', '@b'
        assert.deepEqual queryOperator, qb.eq qb.expr('HAS(a)'), qb.ref('b')
        queryOperator = operatorsMap['$type'] '@a', 'b'
        assert.deepEqual queryOperator, qb.eq qb.expr('TYPENAME(a)'), qb('b')
        queryOperator = operatorsMap['$type'] '@a', '@b'
        assert.deepEqual queryOperator, qb.eq qb.expr('TYPENAME(a)'), qb.ref('b')

        queryOperator = operatorsMap['$mod'] '@a', ['b', 'c']
        assert.deepEqual queryOperator, qb.eq qb.mod(qb.ref('a'), qb('b')), qb 'c'
        queryOperator = operatorsMap['$mod'] 'a', ['b', 'c']
        assert.deepEqual queryOperator, qb.eq qb.mod(qb('a'), qb('b')), qb 'c'
        queryOperator = operatorsMap['$regex'] '@a', '/^beep/'
        assert.deepEqual queryOperator, qb.expr 'REGEX_TEST(a, "^beep", false)'
        queryOperator = operatorsMap['$regex'] 'a', '/^beep/i'
        assert.deepEqual queryOperator, qb.expr 'REGEX_TEST(a, "^beep", true)'

        date = new Date()
        todayInterval = moment().utc()
        todayStart = todayInterval.startOf('day').toISOString()
        todayEnd = todayInterval.clone().endOf('day').toISOString()
        queryOperator = operatorsMap['$td'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb todayStart)
          qb.lt(qb(date), qb todayEnd)
        ]...
        queryOperator = operatorsMap['$td'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb todayStart)
          qb.lt(qb(date), qb todayEnd)
        ]...

        yesterdayInterval = moment().subtract(1, 'days').utc()
        yesterdayStart = yesterdayInterval.startOf('day').toISOString()
        yesterdayEnd = yesterdayInterval.clone().endOf('day').toISOString()
        queryOperator = operatorsMap['$ld'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb yesterdayStart)
          qb.lt(qb(date), qb yesterdayEnd)
        ]...
        queryOperator = operatorsMap['$ld'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb yesterdayStart)
          qb.lt(qb(date), qb yesterdayEnd)
        ]...

        weekInterval = moment().utc()
        weekStart = weekInterval.startOf('week').toISOString()
        weekEnd = weekInterval.clone().endOf('week').toISOString()
        queryOperator = operatorsMap['$tw'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb weekStart)
          qb.lt(qb(date), qb weekEnd)
        ]...
        queryOperator = operatorsMap['$tw'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb weekStart)
          qb.lt(qb(date), qb weekEnd)
        ]...

        lastweekInterval = moment().subtract(1, 'weeks').utc()
        weekStart = lastweekInterval.startOf('week').toISOString()
        weekEnd = lastweekInterval.clone().endOf('week').toISOString()
        queryOperator = operatorsMap['$lw'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb weekStart)
          qb.lt(qb(date), qb weekEnd)
        ]...
        queryOperator = operatorsMap['$lw'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb weekStart)
          qb.lt(qb(date), qb weekEnd)
        ]...

        monthInterval = moment().utc()
        firstDayStart = monthInterval.startOf('month').toISOString()
        lastDayEnd = monthInterval.clone().endOf('month').toISOString()
        queryOperator = operatorsMap['$tm'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...
        queryOperator = operatorsMap['$tm'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...

        lastmonthInterval = moment().subtract(1, 'months').utc()
        firstDayStart = lastmonthInterval.startOf('month').toISOString()
        lastDayEnd = lastmonthInterval.clone().endOf('month').toISOString()
        queryOperator = operatorsMap['$lm'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...
        queryOperator = operatorsMap['$lm'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...

        yearInterval = moment().utc()
        firstDayStart = yearInterval.startOf('year').toISOString()
        lastDayEnd = yearInterval.clone().endOf('year').toISOString()
        queryOperator = operatorsMap['$ty'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...
        queryOperator = operatorsMap['$ty'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...

        lastyearInterval = moment().subtract(1, 'years').utc()
        firstDayStart = lastyearInterval.startOf('year').toISOString()
        lastDayEnd = lastyearInterval.clone().endOf('year').toISOString()
        queryOperator = operatorsMap['$ly'] date, yes
        assert.deepEqual queryOperator, qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...
        queryOperator = operatorsMap['$ly'] date, no
        assert.deepEqual queryOperator, qb.not qb.and [
          qb.gte(qb(date), qb firstDayStart)
          qb.lt(qb(date), qb lastDayEnd)
        ]...
        yield return
  describe '#parseFilter', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get parse filter', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        result = collection.parseFilter
          field: 'a'
          operator: '$eq'
          operand: 'b'
        assert.deepEqual result, qb.eq qb('a'), qb('b')
        result = collection.parseFilter
          parts: [
            operator: '$or'
            parts: [
              field: '@c'
              operand: '1'
              operator: '$eq'
            ,
              field: '@b'
              operand: '2'
              operator: '$eq'
            ]
          ,
            operator: '$nor'
            parts: [
              field: '@d'
              operand: '1'
              operator: '$eq'
            ,
              field: '@b'
              operand: '2'
              operator: '$eq'
            ]
          ]
          operator: '$and'
        assert.deepEqual result, qb.and [
          qb.or qb.eq(qb.ref('c'), qb('1')), qb.eq(qb.ref('b'), qb('2'))
          qb.not qb.or qb.eq(qb.ref('d'), qb('1')), qb.eq(qb.ref('b'), qb('2'))
        ]...
        result = collection.parseFilter
          operator: '$elemMatch'
          field: '@a'
          parts: [
            field: '@b'
            operand: 'c'
            operator: '$eq'
          ]
          implicitField: yes
        assert.deepEqual result, qb.gt qb.expr('LENGTH(a[* FILTER (CURRENT == "c")])'), qb 0
        result = collection.parseFilter
          operator: '$elemMatch'
          field: '@a'
          parts: [
            field: 'b'
            operand: 'c'
            operator: '$eq'
          ]
        assert.deepEqual result, qb.gt qb.expr('LENGTH(a[* FILTER (CURRENT.b == "c")])'), qb 0
        yield return
  describe '#parseQuery', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get parse query for `patch`', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$patch': yield SampleRecord.serialize SampleRecord.new
            createdAt: date
            updatedAt: date
            test: 'test'
            type: 'Test::SampleRecord'
          , collection
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$let':
            k:
              '$forIn':
                'doc1': COL_NAME
              '$filter':
                '@doc1.test': 'test'
              '$return': 'doc1'
          '$return': '@doc'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) LET k = FOR doc1 IN ' + COL_NAME + ' FILTER ((doc1.test == "test")) RETURN doc1 UPDATE doc WITH {"rev": null, "type": "Test::SampleRecord", "isHidden": false, "createdAt": "' + date.toISOString() + '", "updatedAt": "' + date.toISOString() + '", "deletedAt": null, "test": "test"} IN ' + COL_NAME
        yield return
    it 'should get parse query for `remove`', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$remove': 'id': '1'
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$let':
            k:
              '$forIn':
                'doc1': COL_NAME
              '$filter':
                '@doc1.test': 'test'
              '$return': 'doc1'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) LET k = FOR doc1 IN ' + COL_NAME + ' FILTER ((doc1.test == "test")) RETURN doc1 REMOVE {_key: doc._key} IN ' + COL_NAME
        yield return
    it 'should get parse query for other with distinct return', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$let':
            k:
              '$forIn':
                'doc1': COL_NAME
              '$filter':
                '@doc1.test': 'test'
              '$return': 'doc1'
          '$collect':
            l:
              '$forIn':
                'doc2': COL_NAME
              '$filter':
                '@doc2.test': 'test'
              '$return': 'doc2'
          '$having':
            '$and': [
              '$or': [
                'f': '$eq': '1'
              ,
                '@doc.g': '$eq': '2'
              ]
            ,
              '@doc.h':
                '$not': '$eq': '2'
            ]
          '$sort': [
            '@doc.field1': 'ASC'
          ,
            '@doc.field2': 'DESC'
          ]
          '$limit': 100
          '$offset': 50
          '$distinct': yes
          '$return': '@doc'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) LET k = FOR doc1 IN ' + COL_NAME + ' FILTER ((doc1.test == "test")) RETURN doc1 COLLECT l = FOR doc2 IN ' + COL_NAME + ' FILTER ((doc2.test == "test")) RETURN doc2 INTO ' + COL_NAME + ' FILTER (((((("f" == "1")) || ((doc.g == "2")))) && (!(doc.h == "2")))) SORT doc.field1 ASC, doc.field2 DESC LIMIT 50, 100 RETURN DISTINCT doc'
        yield return
    it 'should get parse query for other with count', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$count': yes
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' COLLECT WITH COUNT INTO counter RETURN (counter ? counter : 0)'
        yield return
    it 'should get parse query for other with sum', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$sum': '@doc.test'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' COLLECT AGGREGATE result = SUM(TO_NUMBER(doc.test)) RETURN result'
        yield return
    it 'should get parse query for other with min', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$min': '@doc.test'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' SORT doc.test LIMIT 1 RETURN doc.test'
        yield return
    it 'should get parse query for other with max', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$max': '@doc.test'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' SORT doc.test DESC LIMIT 1 RETURN doc.test'
        yield return
    it 'should get parse query for other with average', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$avg': '@doc.test'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' COLLECT AGGREGATE result = AVG(TO_NUMBER(doc.test)) RETURN result'
        yield return
    it 'should get parse query for other with return', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        date = new Date
        result = yield collection.parseQuery
          '$forIn':
            'doc': COL_NAME
          '$into': COL_NAME
          '$join':
            '$and': [
              '@doc.tomatoId': '$eq': '@tomato._key'
            ,
              '@tomato.active': '$eq': yes
            ]
          '$filter':
            '$and': [
              '$or': [
                'c': '$eq': '1'
              ,
                '@doc.b': '$eq': '2'
              ]
            ,
              '@doc.b':
                '$not': '$eq': '2'
            ]
          '$return':
            'doc': '@doc'
        assert.equal "#{result}", 'FOR doc IN ' + COL_NAME + ' FILTER ((doc.tomatoId == tomato._key) && (tomato.active == true)) FILTER (((((("c" == "1")) || ((doc.b == "2")))) && (!(doc.b == "2")))) INTO ' + COL_NAME + ' RETURN {doc: doc}'
        yield return
  describe '#executeQuery', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should send query to ArangoDB', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        samples = yield collection.executeQuery '
          FOR doc IN ' + COL_NAME + ' ' + '
          SORT doc._key
          LET docWithType = MERGE({}, doc, {type: "Test::TestRecord", id: HASH(doc._key)})
          RETURN docWithType
        '
        items = yield samples.toArray()
        assert.lengthOf items, 4
        for item in items
          assert.instanceOf item, SampleRecord
        items = yield collection.executeQuery '
          FOR doc IN ' + COL_NAME + ' ' + '
          FILTER doc.data == "a boat"
          LET docWithType = MERGE({}, doc, {type: "Test::TestRecord", id: HASH(doc._key)})
          RETURN docWithType
        '
        item = yield items.first()
        assert.equal item.data, 'a boat'
        yield return
  describe '#push', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should put data into collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
        facade.registerProxy collection
        spyPush = sinon.spy collection, 'push'
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        assert.equal record, spyPush.args[0][0]
        testRecord = db._collection(COL_NAME).firstExample id: record.id
        assert.isNotNull testRecord
        yield return
  describe '#remove', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove data from collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        spyQuery = sinon.spy collection, 'query'
        recordId = record.id
        yield record.destroy()
        testRecord = db._collection(COL_NAME).firstExample id: recordId
        assert.isNull testRecord
        yield return
  describe '#take', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get data item by id from collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        recordDuplicate = yield collection.take record.id
        assert.notEqual record, recordDuplicate
        for attribute in SampleRecord.attributes
          assert.equal record[attribute], recordDuplicate[attribute]
        yield return
  describe '#takeMany', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get data items by id list from collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_017'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        ids = originalRecords.map (item) -> item.id
        recordDuplicates = yield (yield collection.takeMany ids).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in SampleRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#takeAll', ->
    before ->
      db._create "#{PREFIX}items"
    after ->
      db._drop "#{PREFIX}items"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get all data items from collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_018'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class ItemRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::ItemRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'ItemRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        ids = originalRecords.map (item) -> item.id
        recordDuplicates = yield (yield collection.takeAll()).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in ItemRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#override', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should replace data item by id in collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_019'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        updatedRecord = yield collection.override record.id, yield collection.build test: 'test2', type: 'Test::SampleRecord'
        assert.isDefined updatedRecord
        assert.equal record.id, updatedRecord.id
        assert.propertyVal record, 'test', 'test1'
        assert.propertyVal updatedRecord, 'test', 'test2'
        yield return
  ###
  describe '#patch', ->
    it 'should update data item by id in collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_020'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        updatedRecord = yield collection.patch record.id, collection.build test: 'test2'
        assert.isDefined updatedRecord
        assert.equal record.id, updatedRecord.id
        assert.propertyVal record, 'test', 'test1'
        assert.propertyVal updatedRecord, 'test', 'test2'
        yield return
  ###
  describe '#includes', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test if item is included in the collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_021'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class SampleRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::SampleRecord'
          @initialize()
        class SampleSerializer extends Test::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'SampleRecord'
          serializer: 'SampleSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        record = yield collection.create test: 'test1'
        assert.isDefined record
        includes = yield collection.includes record.id
        assert.isTrue includes
        yield return
  describe '#length', ->
    before ->
      db._create "#{PREFIX}items"
    after ->
      db._drop "#{PREFIX}items"
    facade = null
    afterEach ->
      facade?.remove?()
      console.log 'ArangoCollectionMixin TESTS END'
    it 'should count items in the collection', ->
      co ->
        collectionName = 'SamplesCollection'
        KEY = 'TEST_ARANGO_COLLECTION_MIXIN_022'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::GenerateUuidIdMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class ItemRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::ItemRecord'
          @initialize()
        class ItemSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include Test::ArangoSerializerMixin
          @module Test
          @initialize()
        collection = ArangoCollection.new collectionName,
          delegate: 'ItemRecord'
          serializer: 'ItemSerializer'
        facade.registerProxy collection
        assert.instanceOf collection, ArangoCollection
        count = 11
        for i in [ 1 .. count ]
          yield collection.create test: 'test1'
        length = yield collection.length()
        assert.equal count, length
        yield return
