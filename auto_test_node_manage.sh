#!/bin/bash
set -e

. ./config.cfg

./run_pybot.sh pybot $variables --include ha valid_node_manage.txt
