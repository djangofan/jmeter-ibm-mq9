#!/bin/bash
## version is 9.1.2.0 at time when this file was created
docker run \
  --name mqdemo \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --env MQ_ENABLE_METRICS=true \
  --env MQ_ENABLE_EMBEDDED_WEB_SERVER=true \
  --publish 1414:1414 \
  --publish 9009:9443 \
  --publish 9157:9157 \
  --volume "$PWD/cert/mykey:/etc/mqm/pki/keys/mykey" \
  --detach \
  ibmcom/mq
  
