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

# Shutdown Hive Metastore
echo "Shutting down Hive Metastore"
killall java

# Clean up data
echo "Cleaning up data"
rm -rf /mnt/kafka-logs/
rm -rf /mnt/zookeeper/
rm -rf /mnt/dfs/name/*
rm -rf /mnt/dfs/data/*
rm -rf /mnt/connect.offsets
rm -rf /mnt/logs/*


