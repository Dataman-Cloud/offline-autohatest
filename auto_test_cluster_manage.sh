#!/bin/bash

. ./config.cfg
. $SRY_DIR/config.cfg

if [ "$OFFLINE_PACKAGE_MOD" == "marathon" ];then
        ./run_pybot.sh pybot --include ha valid_cluster_manage.txt
fi

if [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
        ./run_pybot.sh pybot --include ha valid_cluster_manage_v2.txt
fi
