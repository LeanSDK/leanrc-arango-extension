

module.exports = (Module)->
  {
    NilT
    FuncG, InterfaceG
    GatewayInterface
    EndpointInterface
    Endpoint
    CrudEndpointMixin
    Utils: { joi }
  } = Module::

  class SharingPermitablesListEndpoint extends Endpoint
    @inheritProtected()
    @include CrudEndpointMixin
    @module Module

    @public init: FuncG(InterfaceG(gateway: GatewayInterface), NilT),
      default: (args...)->
        @super args...
        sectionSchema = joi.object
          id:       joi.string()
          actions:  joi.array().items(joi.string())
        @response joi.object(
            permitables: joi.array().items sectionSchema
        ), 'Sections'
          .summary 'Sharing permitables info'
          .description 'Info about sharing permitables for this service'
        return


    @initialize()
