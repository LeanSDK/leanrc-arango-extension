# This file is part of leanrc-arango-extension.
#
# leanrc-arango-extension is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# leanrc-arango-extension is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with leanrc-arango-extension.  If not, see <https://www.gnu.org/licenses/>.

# Класс намеренно подгоняется под интерфейс класса `SyntheticResponse` который используется в недрах аранги.
# однако этот класс будет использоваться при формировании запросов между сервисами вместо http (в ArangoForeignCollectionMixin)


crypto        = require '@arangodb/crypto'
httperr       = require 'http-errors'
mediaTyper    = require 'media-typer'
mimeTypes     = require 'mime-types'
vary          = require 'vary'
typeIs        = require 'type-is'
fs            = require 'fs'
contentDisposition = require 'content-disposition'


module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG, UnionG, SampleG
    CoreObject
    Utils: { _, statuses }
  } = Module::

  MIME_JSON = 'application/json; charset=utf-8'
  MIME_BINARY = 'application/octet-stream'

  class SyntheticResponse extends CoreObject
    @inheritProtected()
    @module Module

    @public body: MaybeG(UnionG Buffer, String),
      set: (data)->
        unless data?
          return undefined
        if _.isString(data) or _.isBuffer data
          return data
        else if _.isObjectLike data
          if @context.isDevelopment
            return JSON.stringify data, null, 2
          else
            return JSON.stringify data
        else
          return String data
    @public context: Object
    @public headers: Object
    @public cookies: Array,
      set: (headers)->
        unless headers
          return {}
        for own name, value of headers
          if name.toLowerCase() is 'content-type'
            @contentType = value
        return headers
    @public statusCode: MaybeG Number
    @public contentType: MaybeG String


    @public attachment: FuncG(String, SampleG SyntheticResponse),
      default: (filename)->
        if filename and not @contentType
          @contentType = mimeTypes.lookup(filename) ? MIME_BINARY
        @set 'Content-Disposition', contentDisposition filename
        return @

    @public download: FuncG([String, MaybeG String], SampleG SyntheticResponse),
      default: (path, filename)->
        @attachment filename ? path
        @sendFile path
        return @

    @public sendFile: FuncG([String, MaybeG UnionG Object, Boolean], SampleG SyntheticResponse),
      default: (filename, opts)->
        if _.isBoolean opts
          opts = lastModified: opts
        unless opts
          opts = {}
        @body = fs.readFileSync filename
        if opts.lastModified or (
          opts.lastModified isnt no and not @headers['last-modified']
        )
          lastModified = new Date fs.mtime(filename) * 1000
          @headers['last-modified'] = lastModified.toUTCString()
        unless @contentType
          @contentType = mimeTypes.lookup(filename) ? MIME_BINARY
        return @

    @public cookie: FuncG([String, String, MaybeG UnionG String, Number, Object], SampleG SyntheticResponse),
      default: (name, value, opts)->
        unless opts
          opts = {}
        else if _.isString opts
          opts = secret: opts
        else if _.isNumber opts
          opts = ttl: opts

        ttl = if _.isNumber(opts.ttl) and opts.ttl isnt Infinity
          opts.ttl
        else
          undefined
        @addCookie(
          @,
          name,
          value,
          ttl,
          opts.path,
          opts.domain,
          opts.secure,
          opts.httpOnly
        )
        if opts.secret
          signature = crypto.hmac opts.secret, value, opts.algorithm
          @addCookie(
            @,
            "#{name}.sig",
            signature,
            ttl,
            opts.path,
            opts.domain,
            opts.secure,
            opts.httpOnly
          )
        return @

    @public getHeader: FuncG(String, MaybeG String),
      default: (name)->
        name = name.toLowerCase()
        if name is 'content-type'
          return @contentType
        return @headers[name]

    @public removeHeader: FuncG(String, SampleG SyntheticResponse),
      default: (name)->
        name = name.toLowerCase()
        if name is 'content-type'
          @contentType = undefined
        delete @headers[name]
        return @

    @public json: FuncG(AnyT, SampleG SyntheticResponse),
      default: (value)->
        unless @contentType
          @contentType = MIME_JSON
        if pretty or @context.isDevelopment
          @body = JSON.stringify value, null, 2
        else
          @body = JSON.stringify value
        return @

    @public redirect: FuncG([UnionG(String, Number), MaybeG String], SampleG SyntheticResponse),
      default: (status, path)->
        unless path
          path = status
          status = undefined
        if status is 'permanent'
          status = 301
        if status or not @statusCode
          @statusCode = status ? 302
        @setHeader 'location', path
        return @

    @public send: FuncG([AnyT, MaybeG String], SampleG SyntheticResponse),
      default: (body, type)->
        if body and body.isArangoResultSet
          body = body.toArray()

        unless type
          type = 'auto'

        contentType = null
        status = @statusCode ? 200
        response = @_responses.get status

        if response
          if response.model and response.model.forClient
            if response.multiple and _.isArray body
              body = body.map (item) -> response.model.forClient item
            else
              body = response.model.forClient body
          if type is 'auto' and response.contentTypes
            type = response.contentTypes[0]
            contentType = type

        if type is 'auto'
          if _.isBuffer body
            type = MIME_BINARY
          else if body and _.isObjectLike body
            type = 'json'
          else
            type = 'html'

        type = mimeTypes.lookup(type) ? type

        handler = null
        for entry in @context.service.types.entries()
          key = entry[0]
          value = entry[1]
          if _.isRegExp key
            match = type.test key
          else if _.isFunction key
            match = key type
          else
            match = typeIs.is key, type

          if match and value.forClient
            contentType = key
            handler = value
            break

        if handler
          result = handler.forClient(body, @, mediaTyper.parse(contentType))
          if result.headers or result.data
            contentType = result.headers['content-type'] ? contentType
            @set result.headers
            body = result.data
          else
            body = result

        @body = body
        if contentType
          @contentType = contentType
        return @

    @public sendStatus: FuncG([UnionG String, Number], SampleG SyntheticResponse),
      default: (status)->
        if _.isString status
          status = statuses status
        message = String statuses[status] ? status
        @statusCode = status
        @body = message
        return @

    @public set: FuncG([UnionG(String, Object), MaybeG String], SampleG SyntheticResponse),
      default: (name, value)->
        if name and _.isObjectLike name
          _.each name, (v, k) => @set k, v
        else
          @setHeader name, value
        return @

    @public setHeader: FuncG([String, String], SampleG SyntheticResponse),
      default: (name, value)->
        unless name
          return @
        name = name.toLowerCase()
        if name is 'content-type'
          @contentType = value
        else
          @headers[name] = value
        return @

    @public status: FuncG([UnionG String, Number], SampleG SyntheticResponse),
      default: (status)->
        if _.isString status
          status = statuses status
        @statusCode = status
        return @

    @public throw: FuncG([UnionG(String, Number), MaybeG(UnionG Error, String, Object), MaybeG Object]),
      default: (status, reason, options)->
        if _.isString status
          status = statuses status

        if _.isError reason
          err = reason
          reason = err.message
          options = Object.assign {
            cause: err,
            errorNum: err.errorNum
          }, options

        if reason and _.isObjectLike reason
          options = reason
          reason = undefined

        throw Object.assign(
          httperr(status, reason),
          {statusCode: status, status},
          options
        )

    @public type: FuncG([MaybeG String], MaybeG String),
      default: (type)->
        if type
          @contentType = mimeTypes.lookup(type) ? type
        @contentType

    @public vary: Function,
      default: (args...)->
        header = @getHeader('vary') ? ''
        values = if args.length is 1
          args[0]
        else
          args
        for value in values
          header = vary.append header, value
        @setHeader 'vary', header
        return @

    @public write: FuncG(AnyT, SampleG SyntheticResponse),
      default: (data)->
        bodyIsBuffer = _.isBuffer @body
        dataIsBuffer = _.isBuffer data
        unless data?
          return @
        unless dataIsBuffer
          if _.isObjectLike data
            if @context.isDevelopment
              data = JSON.stringify data, null, 2
            else
              data = JSON.stringify data
          else
            data = String data
        unless @body
          @body = data
        else if bodyIsBuffer or dataIsBuffer
          bodyB = if bodyIsBuffer then @body else new Buffer @body
          dataB = if dataIsBuffer then data else new Buffer data
          @body = Buffer.concat [bodyB, dataB]
        else
          @body += data
        return @

    @public addCookie: Function,
      default: (res, name, value, lifeTime, path, domain, secure, httpOnly)->
        if name is undefined
          return
        if value is undefined
          return

        cookie = {name, value}

        if lifeTime isnt undefined and lifeTime isnt null
          cookie.lifeTime = parseInt lifeTime, 10
        if path isnt undefined and path isnt null
          cookie.path = path
        if domain isnt undefined and domain isnt null
          cookie.domain = domain
        if secure isnt undefined and secure isnt null
          cookie.secure = if secure then yes else no
        if httpOnly isnt undefined and httpOnly isnt null
          cookie.httpOnly = if httpOnly then yes else no

        res.cookies.push cookie
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: Function,
      default: (context)->
        @super()
        @headers = {}
        @cookies = []
        @context = context
        @_responses = new Map() # перенесена из https://github.com/arangodb/arangodb/blob/69f32f92926dd60958f85dfacf4341478d657a45/js/server/modules/%40arangodb/foxx/router/response.js - но никакого наполнения данными этого мапа не происходит. - очень станный код.
        return


    @initialize()
