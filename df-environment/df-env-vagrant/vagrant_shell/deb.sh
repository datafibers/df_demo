#!/bin/bash

set -e

if [ ! -d /tmp/vagrant-downloads ]; then
    mkdir -p /tmp/vagrant-downloads
fi
chmod a+rw /tmp/vagrant-downloads


# Install Java 8. Uncommen if without proxy
# sudo add-apt-repository -y ppa:webupd8team/java
# sudo apt-get -y update
# sudo apt-get -y install oracle-java8-installer

if [ -z `which javac` ]; then
    sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
	sudo echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
	sudo apt-get -y update
	sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    sudo apt-get -y install oracle-java8-installer
fi

chmod a+rw /opt

if [ ! -e /mnt ]; then
    mkdir /mnt
fi
chmod a+rwx /mnt

# Install and configure Apache Hadoop
pushd /opt/
if [ ! -e hadoop ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e hadoop-2.6.0.tar.gz ]; then
        wget --progress=bar:force http://mirrors.koehn.com/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
    fi
    tar xvzf /tmp/vagrant-downloads/hadoop-2.6.0.tar.gz
    ln -sfn /opt/hadoop-2.6.0 /opt/hadoop
    popd
fi
popd

# Install and configure Hive
pushd /opt/
if [ ! -e hive ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e apache-hive-1.2.1-bin.tar.gz ]; then
        wget --progress=bar:force http://apache.parentingamerica.com/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz
    fi
    tar xvzf /tmp/vagrant-downloads/apache-hive-1.2.1-bin.tar.gz
    ln -sfn /opt/apache-hive-1.2.1-bin /opt/hive
    popd
fi
popd

# Install CP
pushd /opt/
if [ ! -e confluent ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e confluent-3.0.0-2.11.tar.gz ]; then
        wget --progress=bar:force http://packages.confluent.io/archive/3.0/confluent-3.0.0-2.11.tar.gz
    fi
    tar xvzf /tmp/vagrant-downloads/confluent-3.0.0-2.11.tar.gz
    ln -sfn /opt/confluent-3.0.0 /opt/confluent
    popd
fi
popd

# Install Elastic
pushd /opt/
if [ ! -e elasticsearch ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e elasticsearch-2.3.4.tar.gz ]; then
        wget --progress=bar:force https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz
    fi
    tar xvzf /tmp/vagrant-downloads/elasticsearch-2.3.4.tar.gz
    ln -sfn /opt/elasticsearch-2.3.4 /opt/elasticsearch
    popd
fi
popd

# Install Zeppelin
pushd /opt/
if [ ! -e zeppelin ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e zeppelin-0.6.0-bin-all.tgz ]; then
        wget  --progress=bar:force http://mirror.its.dal.ca/apache/zeppelin/zeppelin-0.6.0/zeppelin-0.6.0-bin-all.tgz
    fi
    tar xvzf /tmp/vagrant-downloads/zeppelin-0.6.0-bin-all.tgz
    ln -sfn /opt/zeppelin-0.6.0-bin-all /opt/zeppelin
    popd
fi
popd


#Install Others
sudo cp /opt/hadoop/share/hadoop/tools/lib/hadoop-distcp-2.6.0.jar /opt/hive/lib/
sudo apt-get install -y maven git

# Copy .profile and change owner to vagrant
cp /vagrant/.profile /home/vagrant/
chown vagrant:vagrant /home/vagrant/.profile
source /home/vagrant/.profile

cp -r /vagrant/etc /mnt/
chown -R vagrant:vagrant /mnt/etc
mkdir -p /mnt/logs
chown -R vagrant:vagrant /mnt/logs

mkdir -p /mnt/dfs/name
mkdir -p /mnt/dfs/data

chown -R vagrant:vagrant /mnt/dfs
chown -R vagrant:vagrant /mnt/dfs/name
chown -R vagrant:vagrant /mnt/dfs/data

# Install MySQL Metastore for Hive - do this after creating profiles in order to use hive schematool
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mypassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mypassword'
sudo apt-get -y install mysql-server
sudo apt-get -y install libmysql-java

sudo ln -sfn /usr/share/java/mysql-connector-java.jar /opt/hive/lib/mysql-connector-java.jar
sudo ln -sfn /usr/share/java/mysql-connector-java.jar /opt/confluent/share/java/kafka-connect-jdbc/mysql-connector-java.jar

# Configure Hive Metastore
mysql -u root --password="mypassword" -f \
-e "DROP DATABASE IF EXISTS metastore;"

mysql -u root --password="mypassword" -f \
-e "CREATE DATABASE IF NOT EXISTS metastore;"

mysql -u root --password="mypassword" \
-e "GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost' IDENTIFIED BY 'mypassword'; FLUSH PRIVILEGES;"

schematool -dbType mysql -initSchema

# Get lastest init scripts
rm -f master.zip
rm -rf df_demo-master
wget --progress=bar:force https://github.com/datafibers/df_demo/archive/master.zip
unzip master.zip
cp df_demo-master/df-environment/df-env-app-init/* /home/vagrant/
chmod +x *.sh


