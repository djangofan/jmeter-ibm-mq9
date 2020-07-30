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

## Included Project Files

- simplestExample.jmx - will only work when MQ is configured with no password and no SSL


## Other Information

- https://github.com/ibm-messaging/mq-container/blob/master/docs/usage.md
- https://github.com/ibm-messaging/mq-container/blob/master/docs/developer-config.md
- https://www.blazemeter.com/blog/ibm-mq-testing-with-jmeter-learn-how

- Admin console so you can watch the queue:  https://localhost:9009/ibmmq/console
--  User: admin
--  Password: passw0rd

- Prometheus metrics:  http://localhost:9157/metrics


## Setup MQ Service Script

A bash script to start the default MQ.   This is not persistent but it can be configured to be persistent.

```
#!/bin/bash
## version is 9.1.2.0 at time of this documentation
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

### Other options you can include

- MQ_DEV - Set this to false to stop the default objects being created.
- MQ_ADMIN_PASSWORD - Changes the password of the admin user. Must be at least 8 characters long.
- MQ_APP_PASSWORD


## What It Looks Like

![JMeter Test Plan Example](https://github.com/djangofan/jmeter-ibm-mq9/blob/master/jmeterGui.png)


## Client Setup Code (without SSL)

```
import com.ibm.msg.client.jms.JmsConnectionFactory
import com.ibm.msg.client.jms.JmsFactoryFactory
import com.ibm.msg.client.wmq.WMQConstants

import javax.jms.Session

// 1
def hostName = "127.0.0.1"
def hostPort = 1414
def channelName = "DEV.APP.SVRCONN"
def queueManagerName = "QM1"
def queueName = "DEV.QUEUE.1"

// 2
def ff = JmsFactoryFactory.getInstance(WMQConstants.WMQ_PROVIDER)
def cf = ff.createConnectionFactory()

// 3
cf.setStringProperty(WMQConstants.WMQ_HOST_NAME, hostName)
cf.setIntProperty(WMQConstants.WMQ_PORT, hostPort)
cf.setStringProperty(WMQConstants.WMQ_CHANNEL, channelName)
cf.setIntProperty(WMQConstants.WMQ_CONNECTION_MODE, WMQConstants.WMQ_CM_CLIENT)
cf.setStringProperty(WMQConstants.WMQ_QUEUE_MANAGER, queueManagerName)

//cf.setStringProperty(WMQConstants.USERID, "admin")
//cf.setStringProperty(WMQConstants.PASSWORD, "passw0rd")
//cf.setBooleanProperty(WMQConstants.USER_AUTHENTICATION_MQCSP, true)

// 4
//def conn = cf.createConnection("admin", "passw0rd")
def conn = cf.createConnection()
def sess = conn.createSession(false, Session.AUTO_ACKNOWLEDGE)

// 5
def destination = sess.createQueue(queueName)

conn.start()

log.info("#### Start completed!")

// 6
System.getProperties().put("Session", sess)
System.getProperties().put("Connection", conn)
System.getProperties().put("Destination", destination)

// 7
vars.put("setupDone", "true")

```

## Queue Producer Code

```
import java.time.Instant

// 1
def sess = System.getProperties().get("Session")
def destination = System.getProperties().get("Destination")

// 2
def producer = sess.createProducer(destination)

// 3
def rnd = new Random(System.currentTimeMillis())

// 4
def payload = String.format("JMeter...IBM MQ...test message no. %09d!", rnd.nextInt(Integer.MAX_VALUE))
def msg = sess.createTextMessage(payload)

def start = Instant.now()

// 5
producer.send(msg)

def stop = Instant.now()

// 6
producer.close()

// 7
SampleResult.setResponseData(msg.toString())
SampleResult.setDataType( org.apache.jmeter.samplers.SampleResult.TEXT )
SampleResult.setLatency( stop.toEpochMilli() - start.toEpochMilli() )
```

## Queue Consumer Code

```
import javax.jms.TextMessage
import javax.jms.BytesMessage

import java.time.LocalDate
import java.time.LocalTime
import java.time.Instant
import java.time.format.DateTimeFormatter

log.info("#### Looking for messages to consume...")

// 1
def sess = System.getProperties().get("Session")
def destination = System.getProperties().get("Destination")

// 2
def consumer = sess.createConsumer(destination)

def start = Instant.now()

// 3
def msg = consumer.receive(1000)

def stop = Instant.now()

// 4
if (msg != null) {
            // 5
	if (msg instanceof BytesMessage) {
		def tmp = msg.asType(BytesMessage)
		log.debug("#### Incoming BytesMessage contains " + tmp.getBodyLength() + " bytes")
	} else if (msg instanceof TextMessage) {
		def tmp = msg.asType(TextMessage)
		log.debug("#### Incoming TextMessage contains -> " + tmp.getText())
	} else {
		log.debug("#### Incoming message has unexpected format!")
	}

     // 6
	LocalDate date = LocalDate.parse(msg.getStringProperty("JMS_IBM_PutDate"),
					DateTimeFormatter.ofPattern("uuuuMMdd"))
	LocalTime time = LocalTime.parse(msg.getStringProperty("JMS_IBM_PutTime"),
					DateTimeFormatter.ofPattern("HHmmssSS"))

	// 7
     def timestampDetail = String.format("#### Incoming message was placed in queue @ %s - %s", date, time)
	log.info(timestampDetail)

	// 8
            SampleResult.setResponseData(msg.toString() + "\n\n" + timestampDetail)
	SampleResult.setDataType( org.apache.jmeter.samplers.SampleResult.TEXT )
	SampleResult.setLatency( stop.toEpochMilli() - start.toEpochMilli() )

} else {
	log.info("#### Nothing to fetch!")
}

// 9
consumer.close()

```

## Threads Stop Code

```
System.getProperties().get("Session").close()
System.getProperties().get("Connection").close()

log.info("#### Stop completed!")

// 2
vars.put("stopDone", "true")
```
