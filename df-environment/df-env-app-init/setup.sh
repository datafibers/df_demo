#!/bin/bash
set -e

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mypassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mypassword'
sudo apt-get -y install mysql-server
sudo apt-get -y install libmysql-java

if [ -h /opt/hive/lib/mysql-connector-java.jar ]; then
        sudo rm -f /opt/hive/lib/mysql-connector-java.jar
fi

if [ -h /opt/confluent/share/java/kafka-connect-jdbc/mysql-connector-java.jar ]; then
        sudo rm -f /opt/confluent/share/java/kafka-connect-jdbc/mysql-connector-java.jar
fi

sudo ln -s /usr/share/java/mysql-connector-java.jar /opt/hive/lib/mysql-connector-java.jar
sudo ln -s /usr/share/java/mysql-connector-java.jar /opt/confluent/share/java/kafka-connect-jdbc/mysql-connector-java.jar

# Configure Hive Metastore
mysql -u root --password="mypassword" -f \
-e "DROP DATABASE IF EXISTS metastore;"

mysql -u root --password="mypassword" -f \
-e "CREATE DATABASE IF NOT EXISTS metastore;"

mysql -u root --password="mypassword" \
-e "CREATE USER 'hive'@'localhost' IDENTIFIED BY 'mypassword'; REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost'; GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost'; FLUSH PRIVILEGES;"

schematool -dbType mysql -initSchema

