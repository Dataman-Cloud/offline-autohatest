#!/bin/bash
set -e

. ./config.cfg
. $SRY_DIR/config.cfg

if [ "$OFFLINE_PACKAGE_MOD" == "marathon" ];then
	./run_pybot.sh pybot $PYBOT_VARIABLES --include ha valid_app_manage.txt
fi

if [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
	./run_pybot.sh pybot $PYBOT_VARIABLES --include ha valid_app_v2.txt
fi
