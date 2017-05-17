#!/bin/bash
set -e

. ./config.cfg

token=`./get_token.sh`
./get_roleid_by_name.py --server $SRY_SERVER --token $token --rolename owner

