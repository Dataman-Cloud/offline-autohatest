#!/bin/bash

get_es_list(){
	dig @127.0.0.1 elasticsearch.service.consul|grep 'elasticsearch.service.consul.[[:space:]]0[[:space:]]IN[[:space:]]A'
}

get_es_cluster_health(){
	curl http://$1:9200/_cluster/health
	result=`curl -s http://$1:9200/_cluster/health 2>/dev/null`
	echo $result |python -m json.tool|grep 'status.*green' || return 1
}

es_check(){
	num=`get_es_list|wc -l`
	ip=`get_es_list|head -1|awk '{print $5}'`
	if [ "$num" -gt 2 ] && get_es_cluster_health $ip ;then
		echo "elasticserch is ok."
	else
		echo "elasticsearch is error." && exit 1
	fi
}


es_check
