{ db } = require '@arangodb'
{ assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require '@leansdk/leanrc'
ArangoExtension = require '../../..'
{ co } = LeanRC::Utils
Queues = require '@arangodb/foxx/queues'
internal      = require 'internal'

PREFIX = module.context.collectionPrefix


describe 'ArangoResqueMixin', ->
  describe '.new', ->
    it 'should create resque instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        assert.instanceOf resque, TestResque
        yield return
  describe '#fullQueueName', ->
    it 'should get queue full name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        assert.equal resque.fullQueueName('TEST_QUEUE'), "#{PREFIX}_test_queue"
        yield return
  describe '#ensureQueue', ->
    after ->
      try internal.deleteQueue "#{PREFIX}_test_queue"
    it 'should create queue config', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        resque.onRegister()
        { name, concurrency } = yield resque.ensureQueue 'TEST_QUEUE', 5
        queue = Queues.get name
        assert.propertyVal queue, 'name', "#{PREFIX}_test_queue"
        data = db._queues.document queue.name
        assert.propertyVal data, 'maxWorkers', 5
        yield return
  describe '#getQueue', ->
    after ->
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue"
    it 'should get queue', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        resque.onRegister()
        yield resque.ensureQueue 'TEST_QUEUE', 5
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.propertyVal queue, 'name', "#{PREFIX}_test_queue"
        assert.propertyVal queue, 'concurrency', 5
        yield return
  describe '#removeQueue', ->
    after ->
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue"
    it 'should remove queue', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        resque.onRegister()
        yield resque.ensureQueue 'TEST_QUEUE', 5
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.isDefined queue
        console.log '>>??? !!!', resque.fullQueueName 'TEST_QUEUE'
        yield resque.removeQueue 'TEST_QUEUE'
        console.log '>>??? !!!----'
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.isUndefined queue
        yield return
  describe '#allQueues', ->
    after ->
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
      try internal.deleteQueue "#{PREFIX}_test_queue_3"
      try internal.deleteQueue "#{PREFIX}_test_queue_4"
      try internal.deleteQueue "#{PREFIX}_test_queue_5"
      try internal.deleteQueue "#{PREFIX}_test_queue_6"
    it 'should get all queues', ->
      co ->
        console.log '>>> 111'
        class Test extends LeanRC
          @inheritProtected()
          @include ArangoExtension
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include Test::ArangoResqueMixin
          @module Test
          @initialize()
        resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
        resque.onRegister()
        yield resque.ensureQueue 'TEST_QUEUE_1', 1
        yield resque.ensureQueue 'TEST_QUEUE_2', 2
        yield resque.ensureQueue 'TEST_QUEUE_3', 3
        yield resque.ensureQueue 'TEST_QUEUE_4', 4
        yield resque.ensureQueue 'TEST_QUEUE_5', 5
        yield resque.ensureQueue 'TEST_QUEUE_6', 6
        queues = yield resque.allQueues()
        assert.includeDeepMembers queues, [
          name: "#{PREFIX}_test_queue_1", concurrency: 1
        ,
          name: "#{PREFIX}_test_queue_2", concurrency: 2
        ,
          name: "#{PREFIX}_test_queue_3", concurrency: 3
        ,
          name: "#{PREFIX}_test_queue_4", concurrency: 4
        ,
          name: "#{PREFIX}_test_queue_5", concurrency: 5
        ,
          name: "#{PREFIX}_test_queue_6", concurrency: 6
        ]
        yield return
  describe '#pushJob', ->
    jobId = null
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
    after ->
      if jobId? and (try db._jobs.document jobId)
        db._jobs.remove jobId
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
    it 'should save new job', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 222'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            DATA = data: 'data'
            DATE = new Date Date.now() + 60000
            jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT', DATA, DATE
            job = db._jobs.document jobId
            assert.include job,
              _key: jobId.replace /^_jobs\//, ''
              _id: jobId
              status: 'pending'
              queue: "#{PREFIX}_test_queue_1"
              runs: 0
              delayUntil: DATE.getTime()
              maxFailures: 0
              repeatDelay: 0
              repeatTimes: 0
              repeatUntil: -1
            assert.deepEqual job.type, name: 'resque_executor', mount: '/test'
            assert.deepEqual job.failures, []
            assert.deepEqual job.data.data, DATA

            if jobId? and (try db._jobs.document jobId)
              db._jobs.remove jobId
            yield return
        yield return
  describe '#getJob', ->
    jobId = null
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
    after ->
      if jobId? and (try db._jobs.document jobId)
        db._jobs.remove jobId
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
    it 'should get saved job', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 333'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            DATA = data: 'data'
            DATE = new Date Date.now() + 60000
            jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            assert.include job,
              _key: jobId.replace /^_jobs\//, ''
              _id: jobId
              status: 'pending'
              queue: "#{PREFIX}_test_queue_1"
              runs: 0
              delayUntil: DATE.getTime()
              maxFailures: 0
              repeatDelay: 0
              repeatTimes: 0
              repeatUntil: -1
            assert.deepEqual job.type, name: 'resque_executor', mount: '/test'
            assert.deepEqual job.failures, []
            assert.deepEqual job.data.data, DATA

            if jobId? and (try db._jobs.document jobId)
              db._jobs.remove jobId
            yield return
        yield return
  describe '#deleteJob', ->
    jobId = null
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
    after ->
      if jobId? and (try db._jobs.document jobId)
        db._jobs.remove jobId
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
    it 'should remove saved job', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 444'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            DATA = data: 'data'
            DATE = new Date Date.now() + 60000
            jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            assert.include job,
              _key: jobId.replace /^_jobs\//, ''
              _id: jobId
              status: 'pending'
              queue: "#{PREFIX}_test_queue_1"
              runs: 0
              delayUntil: DATE.getTime()
              maxFailures: 0
              repeatDelay: 0
              repeatTimes: 0
              repeatUntil: -1
            assert.deepEqual job.type, name: 'resque_executor', mount: '/test'
            assert.deepEqual job.failures, []
            assert.deepEqual job.data.data, DATA
            assert.isTrue yield resque.deleteJob 'TEST_QUEUE_1', jobId
            assert.isNull yield resque.getJob 'TEST_QUEUE_1', jobId

            if jobId? and (try db._jobs.document jobId)
              db._jobs.remove jobId
            yield return
        yield return
  describe '#abortJob', ->
    jobId = null
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
    after ->
      if jobId? and (try db._jobs.document jobId)
        db._jobs.remove jobId
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
    it 'should discard job', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            DATA = data: 'data'
            DATE = new Date Date.now() + 60000
            jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            assert.include job,
              _key: jobId.replace /^_jobs\//, ''
              _id: jobId
              status: 'pending'
              queue: "#{PREFIX}_test_queue_1"
              runs: 0
              delayUntil: DATE.getTime()
              maxFailures: 0
              repeatDelay: 0
              repeatTimes: 0
              repeatUntil: -1
            assert.deepEqual job.type, name: 'resque_executor', mount: '/test'
            assert.deepEqual job.failures, []
            assert.deepEqual job.data.data, DATA
            yield resque.abortJob 'TEST_QUEUE_1', jobId
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            assert.include job,
              _key: jobId.replace /^_jobs\//, ''
              _id: jobId
              status: 'failed'
              queue: "#{PREFIX}_test_queue_1"
              runs: 0
              delayUntil: DATE.getTime()
              maxFailures: 0
              repeatDelay: 0
              repeatTimes: 0
              repeatUntil: -1
            assert.deepEqual job.type, name: 'resque_executor', mount: '/test'
            assert.property job.failures[0], 'stack'
            assert.propertyVal job.failures[0], 'message', 'Job aborted.'
            assert.propertyVal job.failures[0], 'name', 'Error'
            assert.deepEqual job.data.data, DATA

            if jobId? and (try db._jobs.document jobId)
              db._jobs.remove jobId
            yield return
        yield return
  describe '#allJobs', ->
    ids = []
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
      Queues.create "#{PREFIX}_test_queue_2", 1
    after ->
      for id in ids
        if id? and (try db._jobs.document id)
          db._jobs.remove id
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
    it 'should list all jobs', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 666'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            # yield resque.ensureQueue 'TEST_QUEUE_2', 1
            DATA = data: 'data'
            DATE = new Date Date.now() + 3600000
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            # ids.push jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            # yield resque.deleteJob 'TEST_QUEUE_1', jobId
            jobs = yield resque.allJobs 'TEST_QUEUE_1'
            assert.lengthOf jobs, 3
            jobs = yield resque.allJobs 'TEST_QUEUE_1', 'TEST_SCRIPT_2'
            assert.lengthOf jobs, 2

            for id in ids
              if id? and (try db._jobs.document id)
                db._jobs.remove id
            yield return
        yield return
  describe '#pendingJobs', ->
    ids = []
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
      Queues.create "#{PREFIX}_test_queue_2", 1
    after ->
      for id in ids
        if id? and (try db._jobs.document id)
          db._jobs.remove id
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
    it 'should list pending jobs', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 77'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            # yield resque.ensureQueue 'TEST_QUEUE_2', 1
            DATA = data: 'data'
            DATE = new Date()
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            ids.push jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            db._jobs.update job._key, status: 'running'
            jobs = yield resque.pendingJobs 'TEST_QUEUE_1'
            assert.lengthOf jobs, 2
            jobs = yield resque.pendingJobs 'TEST_QUEUE_1', 'TEST_SCRIPT_2'
            assert.lengthOf jobs, 1

            for id in ids
              if id? and (try db._jobs.document id)
                db._jobs.remove id
            yield return
        yield return
  describe '#progressJobs', ->
    ids = []
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
      Queues.create "#{PREFIX}_test_queue_2", 1
    after ->
      for id in ids
        if id? and (try db._jobs.document id)
          db._jobs.remove id
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
    it 'should list runnning jobs', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 888'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            # yield resque.ensureQueue 'TEST_QUEUE_2', 1
            DATA = data: 'data'
            DATE = new Date()
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            ids.push jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            db._jobs.update job._key, status: 'progress'
            jobs = yield resque.progressJobs 'TEST_QUEUE_1'
            assert.lengthOf jobs, 1
            jobs = yield resque.progressJobs 'TEST_QUEUE_1', 'TEST_SCRIPT_2'
            assert.lengthOf jobs, 0

            for id in ids
              if id? and (try db._jobs.document id)
                db._jobs.remove id
            yield return
        yield return
  describe '#completedJobs', ->
    ids = []
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
      Queues.create "#{PREFIX}_test_queue_2", 1
    after ->
      for id in ids
        if id? and (try db._jobs.document id)
          db._jobs.remove id
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
    it 'should list complete jobs', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            # yield resque.ensureQueue 'TEST_QUEUE_2', 1
            DATA = data: 'data'
            DATE = new Date()
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            ids.push jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            db._jobs.update job._key, status: 'complete'
            jobs = yield resque.completedJobs 'TEST_QUEUE_1'
            assert.lengthOf jobs, 1
            jobs = yield resque.completedJobs 'TEST_QUEUE_1', 'TEST_SCRIPT_2'
            assert.lengthOf jobs, 0

            for id in ids
              if id? and (try db._jobs.document id)
                db._jobs.remove id
            yield return
        yield return
  describe '#failedJobs', ->
    ids = []
    before ->
      Queues.create "#{PREFIX}_test_queue_1", 1
      Queues.create "#{PREFIX}_test_queue_2", 1
    after ->
      for id in ids
        if id? and (try db._jobs.document id)
          db._jobs.remove id
      try internal.deleteQueue 'default'
      try internal.deleteQueue "#{PREFIX}_test_queue_1"
      try internal.deleteQueue "#{PREFIX}_test_queue_2"
      console.log 'ArangoResqueMixin TESTS END'
    it 'should list failed jobs', ->
      co ->
        yield db._executeTransaction
          collections:
            read: ['_queues']
            write: ['_jobs']
            allowImplicit: yes
          action: co.wrap ->
            console.log '>>> 101010'
            class Test extends LeanRC
              @inheritProtected()
              @include ArangoExtension
              @root "#{__dirname}/config/root"
              @initialize()
            class TestResque extends LeanRC::Resque
              @inheritProtected()
              @include Test::ArangoResqueMixin
              @module Test
              @initialize()
            resque = TestResque.new 'TEST_ARANGO_RESQUE_MIXIN'
            resque.onRegister()
            # yield resque.ensureQueue 'TEST_QUEUE_1', 1
            # yield resque.ensureQueue 'TEST_QUEUE_2', 1
            DATA = data: 'data'
            DATE = new Date()
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_2', 'TEST_SCRIPT_1', DATA, DATE
            ids.push jobId = yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_1', DATA, DATE
            ids.push yield resque.pushJob 'TEST_QUEUE_1', 'TEST_SCRIPT_2', DATA, DATE
            job = yield resque.getJob 'TEST_QUEUE_1', jobId
            db._jobs.update job._key, status: 'failed'
            jobs = yield resque.failedJobs 'TEST_QUEUE_1'
            assert.lengthOf jobs, 1
            jobs = yield resque.failedJobs 'TEST_QUEUE_1', 'TEST_SCRIPT_2'
            assert.lengthOf jobs, 0

            for id in ids
              if id? and (try db._jobs.document id)
                db._jobs.remove id
            yield return
        yield return
