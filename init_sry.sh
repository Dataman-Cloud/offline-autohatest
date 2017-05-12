#!/bin/bash
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir

. ./config.cfg

#高可用测试前准备
#获取token
token=`./get_token.sh`

# create hatest group
groupid=`curl -s -X POST -H "Authorization: $token" $SRY_SERVER/v1/groups -d '{
  "name": "'$SRY_HATEST_USER'",
  "description": "just for ha test"
}'|jq ".data.id"`

#创建集群
vClusterId=`curl -s -X POST $SRY_SERVER/v1/clusters -d '{"groupId": '$groupid', "clusterLabel": "cluster1", "desc": "" }' -H Authorization:$token|jq ".data"`

#向集群添加主机
curl -X PATCH -H Authorization:$token $SRY_SERVER/v1/nodes -d "{
    \"method\": \"add\",
    \"nodeIps\": [\"$DEAFAULT_SLAVE_IP\"],
    \"vClusterId\": $vClusterId
}"

if [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
        roleName="roleID"
        role="5"
else
        roleName="role"
        role="\"owner\""
fi

# create user hatest
curl -X POST -H "Authorization: $token" $SRY_SERVER/v1/accounts -d '{
  "email": "system@dataman-inc.com",
  "password": "'$SRY_HATEST_USER'",
  "title": "",
  "userName": "'$SRY_HATEST_PASSWD'",
  "name": "'$SRY_HATEST_USER'",
  "accountGroups": [
      {
          "groupId": '$groupid',
          "'$roleName'": '$role'
      }
    ]
}'
