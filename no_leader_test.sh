#!/bin/bash
BASE_DIR=$(cd `dirname $0` && pwd)
cd $BASE_DIR

COUNT=50
CHECK_IP="192.168.1.231"
LOGFILE="$BASE_DIR/test.log"

while :
do
	# stop leader on zookeeper
	../ansible.sh master "echo stat | curl -s  telnet://localhost:2181 | grep leader  && docker stop dataman-zookeeper"

	# check leader and restart zookeeper
	for i in `seq 1 $COUNT`
	do
		sleep 1
		LEADER_CHECK=$(curl -s http://$CHECK_IP:8080/v2/info | python -m json.tool | grep mesos_leader | wc -l)
		if [ $LEADER_CHECK -eq 1 ];then
			../ansible.sh master "docker start dataman-zookeeper" && break
		else
			echo "."
		fi
		if [ "$i" -eq "$COUNT" ];then
	        	echo "Reproduce no leader bug on marathon" > $LOGFILE.log
                	exit 1
        	fi
	done
done
