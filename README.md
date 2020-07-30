# jmeter-ibm-mq9

Simplest examples of JMeter with Dockerized IBM MQ9.

## Setup

This example uses JMeter 5.3 .  You can download from the usual location.

The following 3 libs need to be loaded in JMeter lib/ext folder:

- the JMeter plugin manager
- com.ibm.mq.allclient-9.1.5.0.jar
- javax.jms-api-2.0.1.jar

After that, make sure you use the plugins manger to add all the plugins that contain extra charts and graphs.

Then, you will be able to load the project file.


## Other Information

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
