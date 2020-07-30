#!/bin/bash
# https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md
#  https://localhost:9009/ibmmq/console
##    User: admin
##    Password: passw0rd
#  http://localhost:9157/metrics

## Other options:
##  MQ_DEV - Set this to false to stop the default objects being created.
##  MQ_ADMIN_PASSWORD - Changes the password of the admin user. Must be at least 8 characters long.
##  MQ_APP_PASSWORD


docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --env MQ_ENABLE_METRICS=true \
  --env MQ_ENABLE_EMBEDDED_WEB_SERVER=true \
  --publish 1414:1414 \
  --publish 9009:9443 \
  --publish 9157:9157 \
  --detach \
  ibmcom/mq


