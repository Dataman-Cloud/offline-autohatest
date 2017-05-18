#!/bin/bash

. ./config.cfg

echo "clean mysql "
$SRY_DIR/ansible/ansible.sh master "docker stop dataman-borgsphere"

dbs=`mysql -uroot -p$SRY_MYSQL_ROOT_PASSWORD -h$SRY_MYSQL_MASTER_HOST -e "show databases" | grep -Ev 'information_schema|performance_schema|mysql|Database'`

for db in $dbs
do
	mysql -uroot -p$SRY_MYSQL_ROOT_PASSWORD -h$SRY_MYSQL_MASTER_HOST -e "drop database $db; create database $db;"
done

$SRY_DIR/ansible/ansible.sh master "docker start dataman-borgsphere"
