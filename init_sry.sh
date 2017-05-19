#!/bin/bash
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir

. ./config.cfg
set +e

# 租房id
tenantid=""
# 用户组id
groupid=""

# create hatest 租户管理员
create_tenant_admin(){
    tmp_token=$1
    tenantid=`curl -s -X POST -H "Authorization: $tmp_token" $SRY_SERVER/v1/tenants -d '{
	"name":"'$SRY_TENANT_USER'",
	"adminName":"'$SRY_TENANT_USER'",
	"adminAccount":"'$SRY_TENANT_USER'",
	"adminEmail":"'$SRY_TENANT_USER'@dataman-inc.com",
	"adminPwd":"'$SRY_TENANT_PASSWD'",
	"registry":"'$SRY_TENANT_USER'",
	"desc":""
    }'|jq '.data.id'`
}

create_hatest_group(){
    tmp_token=$1
    # create hatest group
    groupid=`curl -s X POST -H "Authorization: $tmp_token" $SRY_SERVER/v1/groups -d '{
	    "name":"'$SRY_HATEST_USER'","description":"just for ha test"
    }'|jq '.data.id'`
}

create_group_admin_user(){
    roleName=$1
    role=$2
    tmp_token=$3

    # create user hatest
    curl -X POST -H "Authorization: $tmp_token" $SRY_SERVER/v1/accounts -d '{
      "email": "'$SRY_HATEST_USER'@dataman-inc.com",
      "title": "",
      "userName": "'$SRY_HATEST_USER'",
      "password": "'$SRY_HATEST_PASSWD'",
      "name": "'$SRY_HATEST_USER'",
      "accountGroups": [
          {
              "groupId": '$groupid',
              "'$roleName'": '$role'
          }
      ]
    }'

}

create_cluster(){
    tmp_token=$1
    #创建集群
    vClusterId=`curl -s -X POST $SRY_SERVER/v1/clusters -d '{"groupId": '$groupid', "clusterLabel": "'$SRY_HATEST_CLUSTER_NAME'", "desc": "" }' -H Authorization:$tmp_token|jq ".data"`
}

add_node_to_tenant(){
    tmp_token=$1
    # 主机分配到租户
    curl -X PATCH -H Authorization:$tmp_token $SRY_SERVER/v1/nodes_by_tenant -d "{
	\"method\":\"add\",\"nodeIps\":[\"$DEAFAULT_SLAVE_IP\"],\"tenantId\":$tenantid
    }"
}

add_host_to_cluster(){
    tmp_token=$1
    #向集群添加主机
    curl -X PATCH -H Authorization:$tmp_token $SRY_SERVER/v1/nodes -d "{
        \"method\": \"add\",
        \"nodeIps\": [\"$DEAFAULT_SLAVE_IP\"],
        \"vClusterId\": $vClusterId
    }"
}


#获取token,default admin
admin_token=`./get_token.sh`
cluster_admin_token=""

if [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
    # 创建租户
    create_tenant_admin $admin_token
    # 获取租户管理员token
    tenant_admin_token=`./get_token.sh $SRY_TENANT_USER $SRY_TENANT_PASSWD`
    # 设置集群管理token为租户管理员token
    cluster_admin_token=$tenant_admin_token
    roleName="roleID"
    role=`./get_roleid_by_name.py --server $SRY_SERVER --token $admin_token --rolename group_admin`
    # 分配主机到租户
    add_node_to_tenant $tenant_admin_token
else
    # 设置集群管理token为admin token
    cluster_admin_token=$admin_token
    roleName="role"
    role="\"owner\""
fi

# 在system租户创建hatest用户组
create_hatest_group $cluster_admin_token
# 在system租户创建集群
create_cluster $cluster_admin_token
# 创建hatest组管理员
create_group_admin_user $roleName $role $cluster_admin_token

sleep 5
# 添加租户主机到集群, 因为在添加主机到集群前需要等待主机分配到租户，所以在这循环重试
for i in `seq 1 10`
do
        sleep 1
	add_host_to_cluster $cluster_admin_token && break || echo ""
        if [ $i -eq $count ];then
                echo -e "\033[31m add_host_to_cluster status is error \033[0m"
                exit 1
        fi
done

