t1 = Date.now()

LeanRC = require '@leansdk/leanrc'
ArangoExtensionMixin = require '../..'

class Test extends LeanRC
  @inheritProtected()
  @include ArangoExtensionMixin
  @include LeanRC::SchemaModuleMixin
  @include LeanRC::TemplatableModuleMixin

  @root __dirname

  require('./transforms/TimestampsArrayTransform') @Module

  require('./mixins/GetPermitablesMixin') @Module
  require('./mixins/ExtendReportFromClientsMixin') @Module

  require('./serializers/ApplicationSerializer') @Module
  # require('./serializers/HttpSerializer') @Module

  require('./records/ReportRecord') @Module
  require('./records/LoggedReportRecord') @Module
  require('./records/ClientRecord') @Module

  require('./migrations/BaseMigration') @Module
  @loadMigrations()

  prefix = './resources/modeling/'
  require("#{prefix}ClientsResource") @Module

  prefix = './resources/sharing/'
  require("#{prefix}SharingPermitablesResource") @Module
  require("#{prefix}SharingLoggedReportsResource") @Module

  require('./resources/ItselfResource') @Module

  require('./ApplicationRouter') @Module

  @loadTemplates()

  require('./mediators/ResqueExecutor') @Module
  require('./mediators/MainSwitch') @Module
  require('./mediators/LoggerModuleMediator') @Module
  require('./mediators/ShellJunctionMediator') @Module
  require('./mediators/ApplicationMediator') @Module

  require('./proxies/MainConfiguration') @Module
  require('./proxies/MainCollection') @Module
  require('./proxies/MainResque') @Module
  require('./proxies/MigrationsCollection') @Module
  require('./proxies/ApplicationGateway') @Module
  require('./proxies/MainRenderer') @Module

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./ApplicationFacade') @Module

  require('./MainApplication') @Module

m = Test.initialize()

console.log 'TEST loaded in', Date.now() - t1

module.exports = m
