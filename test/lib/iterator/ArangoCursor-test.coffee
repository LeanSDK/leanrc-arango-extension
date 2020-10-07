{ db } = require '@arangodb'
{ co, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require '@leansdk/leanrc'
ArangoExtension = require '../../..'
{ co } = LeanRC::Utils

PREFIX = module.context.collectionPrefix

describe 'ArangoCursor', ->
  before ->
    console.log '>???? ArangoCursor START'
    try db._drop "#{PREFIX}_thames_travel"
    collection = db._create "#{PREFIX}_thames_travel"
    date = new Date()
    collection.save id: 1, data: 'three', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 2, data: 'men', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 3, data: 'in', createdAt: date, updatedAt: date
    date = new Date()
    collection.save id: 4, data: 'a boat', createdAt: date, updatedAt: date
  after ->
    db._drop "#{PREFIX}_thames_travel"
  describe '.new', ->
    before ->
      console.log '>???? ArangoCursor .new'
    it 'should create cursor instance', ->
      console.log '>???? ArangoCursor .new 000'
      co ->
        console.log '>???? ArangoCursor .new 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        collection = db["#{PREFIX}_thames_travel"]
        cursor = Test::ArangoCursor.new collectionInstance, collection.all()
        yield return
  describe '#setCollection', ->
    before ->
      console.log '>???? ArangoCursor #setCollection'
    it 'should setup collection', ->
      console.log '>???? ArangoCursor #setCollection 000'
      co ->
        console.log '>???? ArangoCursor #setCollection 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        cursor = Test::ArangoCursor.new()
        cursor.setCollection TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        yield return
  describe '#setIterable', ->
    before ->
      console.log '>???? ArangoCursor #setIterable'
    it 'should setup cursor', ->
      console.log '>???? ArangoCursor #setIterable 000'
      co ->
        console.log '>???? ArangoCursor #setIterable 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        collection = db["#{PREFIX}_thames_travel"]
        cursor = Test::ArangoCursor.new collectionInstance
        cursor.setIterable collection.all()
        yield return
  describe '#next', ->
    before ->
      console.log '>???? ArangoCursor #next'
    it 'should get next values one by one', ->
      console.log '>???? ArangoCursor #next 000'
      co ->
        console.log '>???? ArangoCursor #next 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        assert.equal (yield cursor.next()).data, 'three', 'First item is incorrect'
        assert.equal (yield cursor.next()).data, 'men', 'Second item is incorrect'
        assert.equal (yield cursor.next()).data, 'in', 'Third item is incorrect'
        assert.equal (yield cursor.next()).data, 'a boat', 'Fourth item is incorrect'
        assert.isUndefined (yield cursor.next()), 'Uncoed item is present'
        yield return
  describe '#hasNext', ->
    before ->
      console.log '>???? ArangoCursor #hasNext'
      try db._drop "#{PREFIX}_collection"
      collection = db._create "#{PREFIX}_collection"
      date = new Date()
      collection.save {
        id: 1
        type: 'Test::TestRecord'
        data: 'data'
        createdAt: date
        updatedAt: date
      }
    after ->
      db._drop "#{PREFIX}_collection"
    it 'should check if next value is present', ->
      console.log '>???? ArangoCursor #hasNext 000'
      co ->
        console.log '>???? ArangoCursor #hasNext 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        collection = db["#{PREFIX}_collection"]
        cursor = Test::ArangoCursor.new collectionInstance, collection.all()
        assert.isTrue (yield cursor.hasNext()), 'There is no next value'
        data = yield cursor.next()
        assert.isFalse (yield cursor.hasNext()), 'There is something else'
        yield return
  describe '#toArray', ->
    before ->
      console.log '>???? ArangoCursor #toArray'
    it 'should get array from cursor', ->
      console.log '>???? ArangoCursor #toArray 000'
      co ->
        console.log '>???? ArangoCursor #toArray 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        array = db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        .toArray()
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        records = yield cursor.toArray()
        assert.equal records.length, array.length, 'Counts of input and output data are different'
        for record, index in records
          assert.instanceOf record, TestRecord, "Record #{index} is incorrect"
          assert.equal record.data, array[index].data, "Record #{index} `data` is incorrect"
        yield return
  describe '#close', ->
    before ->
      console.log '>???? ArangoCursor #close'
    it 'should remove records from cursor', ->
      console.log '>???? ArangoCursor #close 000'
      co ->
        console.log '>???? ArangoCursor #close 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        assert.isTrue (yield cursor.hasNext()), 'There is no next value'
        yield cursor.close()
        assert.isFalse (yield cursor.hasNext()), 'There is something else'
        yield return
  describe '#count', ->
    before ->
      console.log '>???? ArangoCursor #count'
    it 'should count records in cursor', ->
      console.log '>???? ArangoCursor #count 000'
      co ->
        console.log '>???? ArangoCursor #count 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        assert.equal (yield cursor.count()), 4, 'Count works incorrectly'
        yield return
  describe '#forEach', ->
    before ->
      console.log '>???? ArangoCursor #forEach'
    it 'should call lambda in each record in cursor', ->
      console.log '>???? ArangoCursor #forEach 000'
      co ->
        console.log '>???? ArangoCursor #forEach 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        spyLambda = sinon.spy co.wrap -> yield return
        yield cursor.forEach spyLambda
        assert.isTrue spyLambda.called, 'Lambda never called'
        assert.equal spyLambda.callCount, 4, 'Lambda calls are not match'
        assert.equal spyLambda.args[0][0].data, 'three', 'Lambda 1st call is not match'
        assert.equal spyLambda.args[1][0].data, 'men', 'Lambda 2nd call is not match'
        assert.equal spyLambda.args[2][0].data, 'in', 'Lambda 3rd call is not match'
        assert.equal spyLambda.args[3][0].data, 'a boat', 'Lambda 4th call is not match'
        yield return
  describe '#map', ->
    before ->
      console.log '>???? ArangoCursor #map'
    it 'should map records using lambda', ->
      console.log '>???? ArangoCursor #map 000'
      co ->
        console.log '>???? ArangoCursor #map 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        console.log '>???? ArangoCursor #map 222'
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        console.log '>???? ArangoCursor #map 333'
        records = yield cursor.map co.wrap (record) ->
          record.data = '+' + record.data + '+'
          console.log '???>....', record.data
          yield return record
        assert.lengthOf records, 4, 'Records count is not match'
        assert.equal records[0].data, '+three+', '1st record is not match'
        assert.equal records[1].data, '+men+', '2nd record is not match'
        assert.equal records[2].data, '+in+', '3rd record is not match'
        assert.equal records[3].data, '+a boat+', '4th record is not match'
        yield return
  describe '#filter', ->
    before ->
      console.log '>???? ArangoCursor #filter'
    it 'should filter records using lambda', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        records = yield cursor.filter co.wrap (record) ->
          yield Test::Promise.resolve record.data.length > 3
        assert.lengthOf records, 2, 'Records count is not match'
        assert.equal records[0].data, 'three', '1st record is not match'
        assert.equal records[1].data, 'a boat', '2nd record is not match'
        yield return
  describe '#find', ->
    before ->
      console.log '>???? ArangoCursor #find'
      collection = db._create "#{PREFIX}_collection"
      date = new Date()
      collection.save id: 1, name: 'Jerome', type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 1, name: 'George', type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 1, name: 'Harris', type: 'Test::TestRecord', createdAt: date, updatedAt: date
    after ->
      db._drop "#{PREFIX}_collection"
    it 'should find record using lambda', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute name: String, { default: 'Unknown' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db["#{PREFIX}_collection"].all()
        record = yield cursor.find co.wrap (record) ->
          yield Test::Promise.resolve record.name is 'George'
        assert.equal record.name, 'George', 'Record is not match'
        record = yield cursor.find co.wrap (record) ->
          yield Test::Promise.resolve record.name is 'Marvel'
        assert.isNull record
        yield return
  describe '#compact', ->
    before ->
      console.log '>???? ArangoCursor #compact'
      collection = db._create "#{PREFIX}_collection"
      date = new Date()
      collection.save id: 1, data: 'men', type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 1, data: null, type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 1, data: 'a boat', type: 'Test::TestRecord', createdAt: date, updatedAt: date
    after ->
      db._drop "#{PREFIX}_collection"
    it 'should get non-empty records from cursor', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_collection SORT item._key RETURN item.data ? item : null
        """
        records = yield cursor.compact()
        assert.lengthOf records, 2, 'Records count not match'
        assert.equal records[0].data, 'men', '1st record is not match'
        assert.equal records[1].data, 'a boat', '2nd record is not match'
        yield return
  describe '#reduce', ->
    before ->
      console.log '>???? ArangoCursor #reduce'
    # facade = null
    # afterEach ->
    #   facade?.remove?()
    #   return
    it 'should reduce records using lambda', ->
      co ->
        # collectionName = 'TestsCollection'
        # KEY = 'TEST_ARANGO_CURSOR_001'
        # facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          # @include LeanRC::MemoryCollectionMixin
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        # facade.registerProxy collectionInstance
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        records = yield cursor.reduce co.wrap((accumulator, item) ->
          accumulator[item.data] = item
          yield return accumulator
        ), {}
        assert.equal records['three'].data, 'three', '1st record is not match'
        assert.equal records['men'].data, 'men', '2nd record is not match'
        assert.equal records['in'].data, 'in', '3rd record is not match'
        assert.equal records['a boat'].data, 'a boat', '4th record is not match'
        yield return
  describe '#first', ->
    before ->
      console.log '>???? ArangoCursor #first'
      collection = db._create "#{PREFIX}_collection"
      date = new Date()
      collection.save id: 1, data: 'Jerome', type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 2, data: 'George', type: 'Test::TestRecord', createdAt: date, updatedAt: date
      date = new Date()
      collection.save id: 3, data: 'Harris', type: 'Test::TestRecord', createdAt: date, updatedAt: date
    after ->
      db._drop "#{PREFIX}_collection"
      console.log 'ArangoCursor TESTS END'
    # facade = null
    # afterEach ->
    #   facade?.remove?()
    it 'should get first record from cursor', ->
      co ->
        # collectionName = 'TestsCollection'
        # KEY = 'TEST_ARANGO_CURSOR_002'
        # facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute data: String, { default: '' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          # @include LeanRC::MemoryCollectionMixin
          @module Test
          @initialize()
        collectionInstance = TestCollection.new 'TEST_COLLECTION',
          delegate: TestRecord
        # facade.registerProxy collectionInstance
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_thames_travel
            SORT item._key
            LET itemWithType = MERGE({}, item, {type: "Test::TestRecord", id: HASH(item._key)})
            RETURN itemWithType
        """
        record = yield cursor.first()
        assert.equal record.data, 'three', '1st record is not match'
        cursor = Test::ArangoCursor.new collectionInstance, db._query """
          FOR item IN #{PREFIX}_collection SORT item._key RETURN item
        """
        record = yield cursor.first()
        assert.equal record.data, 'Jerome', 'Another 1st record is not match'
