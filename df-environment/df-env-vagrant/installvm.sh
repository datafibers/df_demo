#!/bin/bash
echo "************************************************************************"
echo "*******************Welcome DF Environment Setup Guide*******************"
echo "************************************************************************"
echo "Note: In order to run this guide, make sure following soft are installed"
echo "******1. vagrant   - https://www.vagrantup.com        ******************"
echo "******2. virtulbox - https://www.virtualbox.org       ******************"
echo "************************************************************************"
echo "To install all software need, you have following profiles to choose"
echo "******1. latest   - This is the latest stack used for development"
echo "******2. demo     - This is the stable stack for the demo purpose"

while true; do
    read -p "Do you wish to install which profile for VM setup (1 or 2)?" yn
    case $yn in
        [1]* ) make install; break;;
        [2]* ) exit;;
        * ) echo "Please answer 1 or 2.";;
    esac
done