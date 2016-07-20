#!/bin/bash
set -e

# Starting Hadoop
echo "Starting Hadoop"
hadoop-daemon.sh start namenode
hadoop-daemon.sh start datanode

# Starting Confluent Platform
echo "Starting Confluent Platform"
zookeeper-server-start /mnt/etc/zookeeper.properties 1>> /mnt/logs/zk.log 2>>/mnt/logs/zk.log &
sleep 5

kafka-server-start /mnt/etc/server.properties 1>> /mnt/logs/kafka.log 2>> /mnt/logs/kafka.log &
sleep 5

schema-registry-start /mnt/etc/schema-registry.properties 1>> /mnt/logs/schema-registry.log 2>> /mnt/logs/schema-registry.log &
sleep 5

# Starting Hive Metastore
echo "Starting Hive metastore"
hive --service metastore 1>> /mnt/logs/metastore.log 2>> /mnt/logs/metastore.log &

# Start ElasticSearch
echo "Starting ElasticSearch"
/opt/elasticsearch/bin/elasticsearch &

# Start Zeppelin
/opt/zeppelin/bin/zeppelin-daemon.sh start

