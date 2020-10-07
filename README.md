leanrc-arango-extension
================================

LeanRC extension for creating application based on ArangoDB platform.


## For development

Для однотипности ведения процесса разработки надо одинаково настраивать ArangoDB
на локальных компьютерах.
* пароль рута: `0000`
* создаем нужную базу данных `<имя базы данных>`
* точка монтирования для сервиса: `/api`

Удаляем пустое приложение
`sudo rm -rf /var/lib/arangodb3-apps/_db/<имя базы данных>/api/APP`

Вместо него создаем символьную ссылку
`sudo ln -s ~/repositories/<имя приложения>/ /var/lib/arangodb3-apps/_db/<имя базы данных>/api/APP`

Для автоматического релоада кода находясь в папке репозитория:
`gulp watch`

Для того, чтобы собрать дистрибутив, чтобы деплоить на продакшен:
`gulp build`
