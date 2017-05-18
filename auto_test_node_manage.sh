#!/bin/bash
set -e

. ./config.cfg

if [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
	./run_pybot.sh pybot $PYBOT_VARIABLES --include ha valid_node_manage_v2.txt
fi

if [ "$OFFLINE_PACKAGE_MOD" == "marathon" ];then
	./run_pybot.sh pybot $PYBOT_VARIABLES --include ha valid_node_manage.txt
fi
