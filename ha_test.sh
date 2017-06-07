#!/bin/bash
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir
set -e
. ./config.cfg

if [ "x$IS_SINGLE" == "xtrue" ];then
	echo "Standalone does not require high availability tests. "
	exit 1
fi

app_test(){
	$SRY_DIR/check_count_tool.sh app_manage ./auto_test_app_manage.sh 60
}

cluster_test(){
	$SRY_DIR/check_count_tool.sh cluster_manage ./auto_test_cluster_manage.sh 60
}

node_test(){
	$SRY_DIR/check_count_tool.sh node_nanage ./auto_test_node_manage.sh 30
}

es_test(){
        $SRY_DIR/check_count_tool.sh elasticserch ./es_check.sh 30
}

pre_check(){
        date
	# check master all services
	echo "Test before check"
	$SRY_DIR/all_check.sh | grep error && exit 1 || echo 
	$SRY_DIR/elk_check.sh | grep error && exit 1 || echo
	echo "Test before check done."
}

init_sry(){
	date
	# init sry user 
	echo "init sry user"
	./init_sry.sh
}

master_3list_test(){
    date
    if [ "$OFFLINE_PACKAGE_MOD" == "marathon" ];then
        service_3list=`cat master_3service_list.txt|grep -v dataman-swan-master`
    elif [ "$OFFLINE_PACKAGE_MOD" == "swan" ];then
        service_3list=`cat master_3service_list.txt|grep -v dataman-marathon`
    else
        service_3list=`cat master_3service_list.txt`
    fi

    for service in $service_3list;do
	for master in srymaster1 srymaster2 srymaster3 ;do
		sleep 10
		$SRY_DIR/ansible/ansible.sh $master "docker stop $service"
		echo "$master $service has stopped"
		if [ "x$service" == "xdataman-marathon" ] || [ "x$service" == "xdataman-swan-master" ] ;then
			app_test
		elif [ "x$service" == "xdataman-mesos-master" ];then
			node_test
		else
			cluster_test
		fi
		$SRY_DIR/ansible/ansible.sh $master "docker start $service"
		echo "$master $service has been started"
	done
    done
}

master_2list_test(){
    date
    service_2list=`cat master_2service_list.txt`

    for service in $service_2list;do
	for master in srymaster1 srymaster2 ; do
		$SRY_DIR/ansible/ansible.sh $master "docker stop $service"
		if [ "x$service" == "xdataman-keepalived" ];then
			$SRY_DIR/ansible/ansible.sh $master "service network restart"
		fi
		echo "$master $service has stopped"
		node_test
		$SRY_DIR/ansible/ansible.sh $master "docker start $service"
		echo "$master $service has been started"
		sleep 5
	done
    done
}

master_docker_test(){
    date
    service=docker
    for master in srymaster1 srymaster2 srymaster3 ;do
	        $SRY_DIR/ansible/ansible.sh $master "service $service stop"
                echo "$master $service has stopped"
                app_test
		if [ "x$master" != "xsrymaster1" ];then
                	cluster_test
		fi
		node_test
                $SRY_DIR/ansible/ansible.sh $master "service $service start"
		echo "$master $service has been started"
		sleep 10
    done
}

monitor_2list_test(){
    date
    monitor_2list=`cat monitor_2service_list.txt`

    for service in $monitor_2list;do
    	for mhost in globalmonitor1 globalmonitor2;do
	        $SRY_DIR/ansible/ansible.sh $mhost "docker stop $service"
                echo "$mhost $service has stopped"
	        $SRY_DIR/ansible/ansible.sh $mhost "docker start $service"
		echo "$mhost $service has been started"
		sleep 5
    	done
    done
}

elk_4list_test(){
    date
    elk_4list=`cat elk_4service_list.txt`

    for service in $elk_4list;do
	for elkhost in elkmaster1 elkmaster2 elkmaster3 elkslave1;do
		$SRY_DIR/ansible/ansible.sh $elkhost "docker stop $service"
                echo "$elkhost $service has stopped"
		es_test
                $SRY_DIR/ansible/ansible.sh $elkhost "docker start $service"
                echo "$elkhost $service has been started"
		sleep 10
	done
    done
}

pre_check
set +e
init_sry
set -e
master_3list_test
master_2list_test
master_docker_test
#monitor_2list_test
#elk_4list_test

date
echo "High availability test passed."
