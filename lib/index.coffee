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

###
Example of use

```coffee
LeanRC = require '@leansdk/leanrc'
ArangoExtension = require '@leansdk/leanrc-arango-extension'

class TestApp extends LeanRC
  @inheritProtected()
  @include ArangoExtension

  @const ANIMATE_ROBOT: Symbol 'animateRobot'
  @const ROBOT_SPEAKING: Symbol 'robotSpeaking'

  require('./controller/command/StartupCommand') TestApp
  require('./controller/command/PrepareControllerCommand') TestApp
  require('./controller/command/PrepareViewCommand') TestApp
  require('./controller/command/PrepareModelCommand') TestApp
  require('./controller/command/AnimateRobotCommand') TestApp

  require('./view/component/ConsoleComponent') TestApp
  require('./view/mediator/ConsoleComponentMediator') TestApp

  require('./model/proxy/RobotDataProxy') TestApp

  require('./AppFacade') TestApp


module.exports = TestApp.initialize().freeze()
```
###

Extension = (BaseClass) ->
  class extends BaseClass
    @inheritProtected()

    coContext = module.context
    @public @static context: Function,
      default: -> coContext

    require('./iterator/ArangoCursor') @Module

    require('./switch/SyntheticRequest') @Module # needs test
    require('./switch/SyntheticResponse') @Module # needs test
    require('./switch/ArangoRequest') @Module
    require('./switch/ArangoResponse') @Module
    require('./switch/ArangoContext') @Module

    require('./mixins/ArangoForeignCollectionMixin') @Module # needs test
    require('./mixins/ArangoCollectionMixin') @Module
    require('./mixins/ArangoSwitchMixin') @Module # needs retest
    require('./mixins/ArangoResourceMixin') @Module # needs retest
    require('./mixins/CommonLocksResourceMixin') @Module # needs retest
    require('./mixins/ArangoMigrationMixin') @Module
    require('./mixins/ArangoConfigurationMixin') @Module
    require('./mixins/ArangoResqueMixin') @Module
    require('./mixins/ArangoSerializerMixin') @Module
    require('./mixins/ArangoExecutorMixin') @Module
    @initializeMixin()

Reflect.defineProperty Extension, 'name',
  value: 'ArangoExtension'


module.exports = Extension
