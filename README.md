# Acalert

A data pipeline for saving lives.
This is my Insight Data Engineering Project 2017C.

![screen_0](figs/screen_0.png)
![screen_1](figs/screen_1.png)



- ~~Live DEMO~~ (The Insight program has ended, so does the AWS cluster.)
- [Project Slides](https://drive.google.com/open?id=1GSehAzTXAU0JdmulQR1Vnmd3FLVfnhPH6Bj1TcgOkJQ)
- [Project DEMO Video](https://youtu.be/ptfBstqCya0)


## Motivation

Accidents can happen anywhere in our daily lives. It can happen when you are climbing, or driving. In fact, it is the 4th leading cause of death in the U.S. 
Each year, more than 200,000 people died from accidents in the U.S. 
That’s why this is important.

The idea of my project is the following. If we could detect those accidents happening in real-time, we could potentially save lives.
For example, imagine we have real-time streaming data of user activities from wearable devices, or smart phones. Those data would come to a system, which could tell if a user is safe, or in danger. Then, if we find a user in danger, using the GPS location data from the user, we can send medical support if needed.

## Pipeline

![Image of pipeline](figs/pipe.png)

So, I build the following pipeline. I have randomly generated data stream containing user id, time, and acceleration, simulating the data from users’ device. I used an ingestion engine, kafka, to receive the data stream. 
Next, I use spark streaming to consume the data from kafka and perform the data processing. It does two tasks. One is calculating the window-average and window-standard-deviation for each user and each window. The other is taking the original data from each user and each window, compare them to the window-average and window-standard-deviation. Then, based on given criteria, flag a record as normal or anomaly. 
All of the data will then be written into the cassandra database, including window-average and window-standard-deviation. 
Then, a table which only contain the current status of each user is saved in a rethinkDB database. The reason to use a separate rethinkDB database is that, if there is any change in the status table, instead of doing a potentially time-consuming query, rethinkDB will automatically push the real-time update to the dashboard.
Finally, I use flask to build the webUI. 
With 2000 users and a 10 second window, my pipeline can handle 2000~3000 records per second.

## Deployment

### Directory structrue

The directory tree of this github is illustrated as the following:

```
.
├── README.md
├── cassandra
│   └── createTable.py
├── figs
│   ├── pipe.pdf
│   ├── pipe.png
│   ├── screen.pdf
│   ├── screen.png
│   ├── screen_0.png
│   └── screen_1.png
├── flask
│   ├── app
│   │   ├── __init__.py
│   │   ├── static
│   │   │   ├── css
│   │   │   │   ├── bootstrap-theme.css
│   │   │   │   ├── bootstrap-theme.css.map
│   │   │   │   ├── bootstrap-theme.min.css
│   │   │   │   ├── bootstrap-theme.min.css.map
│   │   │   │   ├── bootstrap.css
│   │   │   │   ├── bootstrap.css.map
│   │   │   │   ├── bootstrap.min.css
│   │   │   │   ├── bootstrap.min.css.map
│   │   │   │   ├── button.css
│   │   │   │   ├── ie10-viewport-bug-workaround.css
│   │   │   │   ├── starter-template.css
│   │   │   │   └── table.css
│   │   │   ├── fonts
│   │   │   │   ├── glyphicons-halflings-regular.eot
│   │   │   │   ├── glyphicons-halflings-regular.svg
│   │   │   │   ├── glyphicons-halflings-regular.ttf
│   │   │   │   ├── glyphicons-halflings-regular.woff
│   │   │   │   └── glyphicons-halflings-regular.woff2
│   │   │   └── js
│   │   │       ├── bootstrap.js
│   │   │       ├── bootstrap.min.js
│   │   │       ├── ie10-viewport-bug-workaround.js
│   │   │       ├── movingTrace.js
│   │   │       ├── npm.js
│   │   │       ├── plot.js
│   │   │       ├── rethinkDB.js
│   │   │       └── socketwork.js
│   │   ├── templates
│   │   │   ├── aboutMe.html
│   │   │   ├── base.html
│   │   │   ├── index.html
│   │   │   └── mybase.html
│   │   └── views.py
│   ├── run.py
│   └── tornadoapp.py
├── kafka
│   ├── createTopic.sh
│   ├── kafka_producer.py
│   └── run_kafka_producer.sh
├── pegasus
│   └── install_env.sh
├── rethinkDB
│   └── createTable.py
└── spark
    ├── note.txt
    ├── run_streaming.sh
    └── streaming.py
```


### Requirement
[pegasus](https://github.com/insightdatascience/pegasus)

Install pegasus and replace `pegasus/install/environment/install_env.sh` with the `pegasus/install_env.sh` in this github directory.

### Kafka

1. Use pegasus to spin up a kafka cluster with 3 m3.medium nodes. 
2. Use pegasus to install and start zookeeper and kafka.   
3. Copy the `kafka` folder in this github directory to the home directory of the master node of the kafka cluster. And ssh to the master node.
4. Create a kafka topic with `kafka/createTopic.sh`.
5. Install the python driver for kafka with:
``` 
pip install kafka-python
```
6. Create a `kafka/config.py` file and add following lines with your value:
``` 
KAFKA_SERVERS  =  public DNS and port of the servers
ANOMALY_PERIOD =  How often to create an outlier  
ANOMALY_VALUE  =  The value to add to create an outlier
```
7. Then, you can start to simulate data into kafka by running `kafka/run_kafka_producer.sh`.

### Cassandra

1. Use pegasus to spin up a cassandra cluster with 3 m3.medium nodes. 
2. Use pegasus to install and start cassandra.   
3. Copy the `cassandra` folder in this github directory to the home directory of the master node of the cassandra cluster. And ssh to the master node.
4. Install the python driver for cassandra with:
``` 
pip install cassandra-driver
```
5. Create a `cassandra/config.py` file and add following lines with your value:
``` 
CASSANDRA_SERVER    = public DNS and port of the servers
CASSANDRA_NAMESPACE = the namespace in cassandra 
```
6. Then, create a table in cassandra database with `cassandra/createTable.py`

### rethinkDB
1. Use pegasus to spin up a rethinkDB node with 1 m4.large.
2. Copy the `rethinkDB` folder in this github directory to the home directory of the node of the rethinkDB cluster. And ssh to the master node.
3. Install rethinkDB as described on the [offical website](https://rethinkdb.com/docs/install/ubuntu/): 
4. Install the python driver for rethinkDB with:
``` 
pip install rethinkdb
```
5. Create a `rethinkdb/config.py` file and add following lines with your value:
``` 
RETHINKDB_SERVER     = public DNS and port of the servers
RETHINKDB_DB         = name of the database (ex. test) 
RETHINKDB_TABLE      = name of the table (ex.status)
RETHINKDB_PRIMARYKEY = column for primary key
```
6. Then, create a table in rethinkDB database with `rethinkDB/createTable.py`

### Spark streaming

1. Use pegasus to spin up a spark cluster with 4 m4.large nodes. 
2. Use pegasus to install and start hadoop and spark.   
3. Copy the `spark` folder in this github directory to the home directory of the master node of the spark cluster. And ssh to the master node.
4. Install pyspark with:
``` 
conda install pyspark
```
5. Modify the configuration files in spark by following `spark/note.txt`.
6. Create a `spark/config.py` file and add following lines with your value:
``` 
KAFKA_SERVERS       = public DNS and port of kafka servers
CHECKPOINT_DIR      = check point folder for window process  
ANOMALY_CRITERIA    = if abs(data - avg) > config.ANOMALY_CRITERIA * std,
                      then data is an anomaly
RETHINKDB_SERVER    = public DNS of the rethinkDB server
RETHINKDB_DB        = name of the database in rethinkDB
RETHINKDB_TABLE     = name of the table in rethinkDB
CASSANDRA_SERVERS   = public DNS and port of cassandra servers
CASSANDRA_NAMESPACE = namespace for cassandra
```
7. Then, you can submit your spark job by:
```
/usr/local/spark/bin/spark-submit --master spark://<master-hostname>:7077 --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.0.2 streaming.py
```

### Flask
1. Copy the `flask` folder in this github directory to the home directory of the node of the rethinkDB cluster. And ssh to the node.
2. Install cassandra python driver as described in the cassandra session.
3. Use pip to install flask_socketio module.
4. Create a `flask/app/config.py` file and add following lines with your value:
``` 
RETHINKDB_SERVER    = public DNS of the rethinkDB server
RETHINKDB_DB        = name of the database in rethinkDB
RETHINKDB_TABLE     = name of the table in rethinkDB
CASSANDRA_SERVERS   = public DNS and port of cassandra servers
CASSANDRA_NAMESPACE = namespace for cassandra
```
5. Then, run the following command to start the webserver:
```
cd flask
sudo nohup /home/ubuntu/anaconda3/bin/python3 tornadoapp.py &
```




## Future work

There are many future works to improve this project.
1. More stress testing. For example, take down a node in the kafka cluster, spark cluster, or cassandra cluster and see how the pipeline react to those situation.
2. So far, all of the records in the data streaming are ordered. But, in reality, the records in the data stream could be unordered. Then, the stream processing will need to window based on event-time instead of arriving time. In that case, the spark streaming in the pipeline will need to be replaced with spark structured streaming.
3. The criteria to detect anomaly currently is based only on window-average and window-standard-deviation. The ideal solution would be adding additional component to allow data scientist build a ML model and tune the parameters.

