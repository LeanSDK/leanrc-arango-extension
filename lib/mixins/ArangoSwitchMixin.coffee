# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# здесь должна быть реализация интерфейса SwitchInterface работающая с Foxx роутером.

_             = require 'lodash'
inflect       = require('i')()
FoxxRouter    = require '@arangodb/foxx/router'
{ db }        = require '@arangodb'
queues        = require '@arangodb/foxx/queues'
crypto        = require '@arangodb/crypto'
status        = require 'statuses'
{ errors }    = require '@arangodb'

ARANGO_NOT_FOUND  = errors.ERROR_ARANGO_DOCUMENT_NOT_FOUND.code
ARANGO_DUPLICATE  = errors.ERROR_ARANGO_UNIQUE_CONSTRAINT_VIOLATED.code
ARANGO_CONFLICT   = errors.ERROR_ARANGO_CONFLICT.code
HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'

# здесь (наверху) надо привести пример использования в приложении
###
```coffee
module.exports = (Module)->
  class HttpSwitch extends Module::Switch
    @inheritProtected()
    @include Module::ArangoSwitchMixin

    @module Module

    @public routerName: String,
      default: 'ApplicationRouter'
    @public jsonRendererName: String,
      default: 'JsonRenderer'  # or 'ApplicationRenderer'
  HttpSwitch.initialize()
```
###


module.exports = (Module)->
  Module.defineMixin (BaseClass) ->
    class ArangoSwitchMixin extends BaseClass
      @inheritProtected()

      @public getLocks: Function,
        args: []
        return: Object
        default: ->
          vrCollectionPrefix = new RegExp "^#{module.context.collectionPrefix}"
          vlCollectionNames = db._collections().reduce (alResults, aoCollection) ->
            if vrCollectionPrefix.test name = aoCollection.name()
              alResults.push name
            alResults
          , []
          return read: vlCollectionNames, write: vlCollectionNames

      @public handler: Function,
        default: (resourceName, {req, res, reverse}, {method, path, resource, action})->
          try
            voMessage = {
              queryParams: req.queryParams
              pathPatams: req.pathPatams
              currentUserId: req.session.uid
              headers: req.headers
              body: req.body
              reverse
            }
            if method is 'get'
              @sendNotification resourceName, voMessage, action
            else
              {read, write} = @getLocks()
              self = @
              db._executeTransaction
                waitForSync: yes
                collections:
                  read: read
                  write: write
                  allowImplicit: yes
                action: (params)->
                  params.self.sendNotification params.resourceName, params.message, params.action
                params: {resourceName, action, message: voMessage, self}
            queues._updateQueueDelay()
          catch err
            console.log '???????????????????!!', JSON.stringify err
            if err.isArangoError and err.errorNum is ARANGO_NOT_FOUND
              res.throw HTTP_NOT_FOUND, err.message
              return
            if err.isArangoError and err.errorNum is ARANGO_CONFLICT
              res.throw HTTP_CONFLICT, err.message
              return
            else if err.statusCode?
              console.error err.message, err.stack
              res.throw err.statusCode, err.message
            else
              console.error 'kkkkkkkk', err.message, err.stack
              res.throw 500, err.message, err.stack
              return
          return

      @public createNativeRoute: Function,
        default: ({method, path, resource, action})->
          voRouter = FoxxRouter()
          resourceName = inflect.camelize inflect.underscore "#{resource.replace /[/]/g, '_'}Stock"

          voEndpoint = voRouter[method]? [path, (req, res)=>
            reverse = crypto.genRandomAlphaNumbers 32
            @getViewComponent().once reverse, (voData)=>
              @sendHttpResponse req, res, voData, {method, path, resource, action}
            @handler resourceName, {req, res, reverse}, {method, path, resource, action}
          , action]...
          @defineSwaggerEndpoint voEndpoint

          module.context.use voRouter
          return


    ArangoSwitchMixin.initializeMixin()
