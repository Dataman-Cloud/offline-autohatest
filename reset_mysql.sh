#!/bin/bash

. ./config.cfg

echo "clean mysql "
db=auth
$SRY_DIR/ansible/ansible.sh master "docker stop dataman-borgsphere"
mysql -uroot -p$SRY_MYSQL_ROOT_PASSWORD -h$SRY_MYSQL_MASTER_HOST -e "drop database $db; create database $db;"
$SRY_DIR/ansible/ansible.sh master "docker start dataman-borgsphere"
