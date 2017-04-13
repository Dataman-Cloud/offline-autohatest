#!/bin/bash
# Authou: jyliu
# Date: 2016-11-10

. ./config.cfg

BASE_URL=$SRY_SERVER

get_token(){
    token=`curl -s -X POST $BASE_URL/v1/login -d '{"userName":"'$SRY_ADMIN_USER'", "password":"'$SRY_ADMIN_PASSWD'"}' | awk -F \" '{print $6}'`
    echo "$token" > /tmp/sry_token
}

token=`cat /tmp/sry_token 2>/dev/null || echo`
if [ -z "$token" ];then
    echo "111111"
    get_token
fi

curl -s -X GET -H 'Authorization: '$token'' $BASE_URL/v1/aboutme | grep '"code":[[:space:]]*1' &>/dev/null && get_token

echo -n "$token"
