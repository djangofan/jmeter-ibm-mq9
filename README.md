# jmeter-ibm-mq9

Simplest examples of JMeter with Dockerized IBM MQ9.

## Information


- https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md
- https://github.com/ibm-messaging/mq-container/blob/master/docs/developer-config.md
- https://www.blazemeter.com/blog/ibm-mq-testing-with-jmeter-learn-how

- https://localhost:9009/ibmmq/console
--  User: admin
--  Password: passw0rd

- http://localhost:9157/metrics

- Version found at: https://hub.docker.com/_/ibm-mq-advanced -- 9.1.2.0

## Other options

- MQ_DEV - Set this to false to stop the default objects being created.
- MQ_ADMIN_PASSWORD - Changes the password of the admin user. Must be at least 8 characters long.
- MQ_APP_PASSWORD


## Setup MQ Script

A bash script to start the default MQ.   This is not persistent but it can be configured to be persistent.

```
#!/bin/bash
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

```
