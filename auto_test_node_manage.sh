#!/bin/bash
set -e

. ./config.cfg

./run_pybot.sh pybot $PYBOT_VARIABLES --include ha valid_node_manage.txt
