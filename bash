#!/usr/bin/env bash

BOTTOM=$(grep BOTTOM .env | cut -d '=' -f2 | cut -d '#' -f1)
echo

if [ $BOTTOM = "host" ]; then
  APP_PATH=$PWD
elif [ $BOTTOM = "machine" ]; then
  APP_PATH=${PWD/home/hosthome}
fi

docker run --rm -it \
  -e APP_PATH=${APP_PATH} \
  -v ${APP_PATH}/tmp:/tmp \
  -v ${APP_PATH}:/usr/src/leanrc-arango-extension \
  -v ${APP_PATH}/.bash_history:/root/.bash_history \
  -w /usr/src/leanrc-arango-extension \
  node:14.9.0-buster \
  bash

echo
echo
