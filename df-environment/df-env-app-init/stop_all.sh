#!/bin/bash
set -e

# Shutdown Confluent Platform
echo "Shutting down Confluent Platform"
schema-registry-stop /mnt/etc/schema-registry.properties 1>> /mnt/logs/schema-registry.log 2>> /mnt/logs/schema-registry.log &
kafka-server-stop /mnt/etc/server.properties 1>> /mnt/logs/kafka.log 2>> /mnt/logs/kafka.log &
zookeeper-server-stop /mnt/etc/zookeeper.properties 1>> /mnt/logs/zk.log 2>>/mnt/logs/zk.log &

# Shutdown Hadoop
echo "Shutting down Hadoop"
hadoop-daemon.sh stop datanode
hadoop-daemon.sh stop namenode

# Stop Zeppelin
echo "Shutting down Zeppelin"
/opt/zeppelin/bin/zeppelin-daemon.sh stop

# Shutdown Hive Metastore and ElasticSearch
echo "Shutting down all other Java process, Hive Meta, ElasticSearch"
killall java





