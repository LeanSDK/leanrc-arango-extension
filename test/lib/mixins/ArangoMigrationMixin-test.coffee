{ db }  = require '@arangodb'

{ expect, assert } = require 'chai'
sinon = require 'sinon'

LeanRC = require '@leansdk/leanrc'

ArangoExtension = require '../../..'
{ co } = LeanRC::Utils

PREFIX = 'test_'


describe 'ArangoMigrationMixin', ->
  # before ->
  #   db._create "#{PREFIX}migrations"
  after ->
    db._truncate "#{PREFIX}migrations"
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create migration instance', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @initialize()
        collection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy collection
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, collection
        yield return
  describe '#createCollection', ->
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step for create collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @createCollection 'tests'
          @initialize()
        collection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy collection
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, collection
        # collection.initializeNotifier 'TEST'
        # migration = collection.build {}
        spyCreateCollection = sinon.spy migration, 'createCollection'
        yield migration.up()
        assert.isTrue spyCreateCollection.calledWith 'tests'
        collectionFullName = collection.collectionFullName 'tests'
        assert.isNotNull db._collection collectionFullName
        yield return
  describe '#createEdgeCollection', ->
    after ->
      db._drop "#{PREFIX}cucumber_tomatos"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step for create edge collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @createEdgeCollection 'cucumber', 'tomatos'
          @initialize()
        collection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy collection
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, collection
        # collection.initializeNotifier 'TEST'
        # migration = collection.build {}
        spyCreateCollection = sinon.spy migration, 'createEdgeCollection'
        yield migration.up()
        assert.isTrue spyCreateCollection.calledWith 'cucumber', 'tomatos'
        # collectionFullName = collection.collectionFullName "#{PREFIX}cucumber_tomatos"
        assert.isNotNull db._collection "#{PREFIX}cucumber_tomatos"#collectionFullName
        yield return
  describe '#addField', ->
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to add field in record at collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @initialize()
        class Migration1 extends BaseMigration
          @inheritProtected()
          @module Test
          @change ->
            @createCollection 'tests'
          @initialize()
        class Migration2 extends BaseMigration
          @inheritProtected()
          @module Test
          @change ->
            @addField 'tests', 'test',
              type: 'string'
              default: 'Test1'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class ArangoTestCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        # facade.registerProxy ArangoTestCollection.new 'TestCollection',
        #   delegate: TestRecord
        migrationsCollection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        migration1 = Migration1.new {type: 'Test::Migration1'}, migrationsCollection
        yield migration1.up()
        testsCollection = ArangoTestCollection.new 'TestsCollection',
          delegate: 'TestRecord'
        facade.registerProxy testsCollection
        yield testsCollection.create id: 1
        yield testsCollection.create id: 2
        yield testsCollection.create id: 3
        migration2 = Migration2.new {type: 'Test::Migration2'}, migrationsCollection
        yield migration2.up()
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.propertyVal doc, 'test', 'Test1'
        yield return
  describe '#addIndex', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to add index in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        fields = [ 'test' ]
        options = type: 'hash', unique: yes, sparse: yes
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @addIndex 'tests', fields, options
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyAddIndex = sinon.spy migration, 'addIndex'
        yield migration.up()
        assert.isTrue spyAddIndex.calledWith 'tests', fields, options
        indexes = db["#{PREFIX}tests"].getIndexes()
        assert.isTrue indexes.some ({ type, fields, unique, sparse }) ->
          type is 'hash' and 'test' in fields and unique and sparse
        yield return
  describe '#addTimestamps', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.save {}
      collection.save {}
      collection.save {}
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to add timesteps in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @addTimestamps 'tests'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        class ArangoTestCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyAddTimestamps = sinon.spy migration, 'addTimestamps'
        yield migration.up()
        assert.isTrue spyAddTimestamps.calledWith 'tests'
        yield return
  describe '#changeCollection', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests",
        waitForSync: no
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to change collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        options =
          waitForSync: yes
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @changeCollection 'tests', options
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new collectionName,
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyChangeCollection = sinon.spy migration, 'changeCollection'
        assert.propertyVal db._collection("#{PREFIX}tests").properties(), 'waitForSync', no
        yield migration.up()
        assert.isTrue spyChangeCollection.calledWith 'tests', options
        assert.propertyVal db._collection("#{PREFIX}tests").properties(), 'waitForSync', yes
        yield return
  describe '#changeField', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.save test: '42'
      collection.save test: '42'
      collection.save test: '42'
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to change field in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @changeField 'tests', 'test', type: LeanRC::Migration::SUPPORTED_TYPES.integer
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        yield migration.up()
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.propertyVal doc, 'test', 42
        yield return
  describe '#renameField', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.save test: '42'
      collection.save test: '42'
      collection.save test: '42'
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to rename field in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @renameField 'tests', 'test', 'test1'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        yield migration.up()
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.notProperty doc, 'test'
          assert.property doc, 'test1'
        yield return
  describe '#renameIndex', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to rename index in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @renameIndex 'ARG_1', 'ARG_2', 'ARG_3'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyRenameIndex = sinon.spy migration, 'renameIndex'
        yield migration.up()
        assert.isTrue spyRenameIndex.calledWith 'ARG_1', 'ARG_2', 'ARG_3'
        yield return
  describe '#renameCollection', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
    after ->
      try db._drop "#{PREFIX}tests"
      try db._drop "#{PREFIX}new_tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to rename collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @renameCollection 'tests', 'new_tests'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyRenameCollection = sinon.spy migration, 'renameCollection'
        assert.isNotNull db._collection "#{PREFIX}tests"
        yield migration.up()
        assert.isTrue spyRenameCollection.calledWith 'tests', 'new_tests'
        assert.isNull db._collection "#{PREFIX}tests"
        assert.isNotNull db._collection "#{PREFIX}new_tests"
        yield return
  describe '#dropCollection', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.save test: '42'
      collection.save test: '42'
      collection.save test: '42'
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to drop collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @dropCollection 'tests'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        yield migration.up()
        assert.isNull db._collection "#{PREFIX}tests"
        yield return
  describe '#dropEdgeCollection', ->
    before ->
      db._createEdgeCollection "#{PREFIX}tests_tests"
    after ->
      db._drop "#{PREFIX}tests_tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to drop edge collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @dropEdgeCollection 'tests', 'tests'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        yield migration.up()
        assert.isNull db._collection "#{PREFIX}tests_tests"
        yield return
  describe '#removeField', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.save test: '42'
      collection.save test: '42'
      collection.save test: '42'
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to remove field in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'TestRecord'
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @removeField 'tests', 'test'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        yield migration.up()
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.notProperty doc, 'test'
        yield return
  describe '#removeIndex', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      collection.ensureIndex type: 'hash', fields: [ 'test' ], unique: yes,  sparse: yes
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should apply step to remove index in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        fields = [ 'test' ]
        options = type: 'hash', unique: yes,  sparse: yes
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @removeIndex 'tests', fields, options
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        spyRemoveIndex = sinon.spy migration, 'removeIndex'
        indexes = db["#{PREFIX}tests"].getIndexes()
        assert.isTrue indexes.some ({ type, fields, unique, sparse }) ->
          type is 'hash' and 'test' in fields and unique and sparse
        yield migration.up()
        assert.isTrue spyRemoveIndex.calledWith 'tests', fields, options
        indexes = db["#{PREFIX}tests"].getIndexes()
        assert.isFalse indexes.some ({ type, fields, unique, sparse }) ->
          type is 'hash' and 'test' in fields and unique and sparse
        yield return
  describe '#removeTimestamps', ->
    before ->
      db._createDocumentCollection "#{PREFIX}tests"
      collection = db._collection "#{PREFIX}tests"
      DATE = new Date()
      collection.save test: '42', createdAt: DATE, updatedAt: DATE, deletedAt: null
      collection.save test: '42', createdAt: DATE, updatedAt: DATE, deletedAt: null
      collection.save test: '42', createdAt: DATE, updatedAt: DATE, deletedAt: null
    after ->
      db._drop "#{PREFIX}tests"
    facade = null
    afterEach ->
      facade?.remove?()
      console.log 'ArangoMigrationMixin TESTS END'
    it 'should apply step to remove timestamps in collection', ->
      co ->
        collectionName = 'MigrationsCollection'
        KEY = 'TEST_ARANGO_MIGRATION_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root __dirname
          @initialize()
        class BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include Test::ArangoMigrationMixin
          @module Test
          @change ->
            @removeTimestamps 'tests'
          @initialize()
        class ArangoMigrationCollection extends LeanRC::Collection
          @inheritProtected()
          @include Test::QueryableCollectionMixin
          @include Test::ArangoCollectionMixin
          @module Test
          @initialize()
        migrationsCollection = ArangoMigrationCollection.new 'MIGRATIONS',
          delegate: 'BaseMigration'
        facade.registerProxy migrationsCollection
        # migrationsCollection.initializeNotifier 'TEST_MIGRATION'
        migration = BaseMigration.new {type: 'Test::BaseMigration'}, migrationsCollection
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.property doc, 'createdAt'
          assert.property doc, 'updatedAt'
          assert.property doc, 'deletedAt'
        yield migration.up()
        for doc in db._collection("#{PREFIX}tests").all().toArray()
          assert.notProperty doc, 'createdAt'
          assert.notProperty doc, 'updatedAt'
          assert.notProperty doc, 'deletedAt'
        yield return
