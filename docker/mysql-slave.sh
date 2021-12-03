#!/bin/bash

# check mysql master run status

set -e

until MYSQL_PWD=root mysql -u root -h storm-mysql-master ; do
  >&2 echo "MySQL master is unavailable - sleeping"
  sleep 3
done

# create replication user

# mysql_net=$(ip route | awk '$1=="default" {print $3}' | sed "s/\.[0-9]\+$/.%/g")

MYSQL_PWD=root mysql -u root \
-e "CREATE USER 'slave'@'storm-mysql-slave' IDENTIFIED BY 'slave'; \
GRANT REPLICATION SLAVE ON *.* TO 'slave'@'storm-mysql-slave';"

# get master log File & Position

master_status_info=$(MYSQL_PWD=root mysql -u root -h storm-mysql-master -e "show master status\G")

LOG_FILE=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="File:" {print $2}')
LOG_POS=$(echo "${master_status_info}" | awk 'NR!=1 && $1=="Position:" {print $2}')

# stop
MYSQL_PWD=root mysql -u root -e "STOP SLAVE;"

# set node master

MYSQL_PWD=root mysql -u root \
-e "CHANGE MASTER TO MASTER_HOST='storm-mysql-master', \
MASTER_USER='root', \
MASTER_PASSWORD='root', \
MASTER_LOG_FILE='${LOG_FILE}', \
MASTER_LOG_POS=${LOG_POS};"

# start slave and show slave status

MYSQL_PWD=root mysql -u root -e "START SLAVE;show slave status\G"