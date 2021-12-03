#!/bin/bash

set -e

# create replication user

# mysql_net=$(ip route | awk '$1=="default" {print $3}' | sed "s/\.[0-9]\+$/.%/g")

MYSQL_PWD=root mysql -u root \
-e "CREATE USER 'slave'@'storm-mysql-master' IDENTIFIED BY 'slave'; \
GRANT REPLICATION SLAVE ON *.* TO 'slave'@'storm-mysql-master';FLUSH PRIVILEGES;"