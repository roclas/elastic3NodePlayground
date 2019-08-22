#!/usr/bin/env bash

elastic_writeToNode () {
	dateNow="$(date +"%Y-%m-%dT%T.%3N")" 
	curl -X PUT "http://$1:$2/$3/testliferaydocument/$4" -H 'Content-Type: application/json' -d'
	{
		"user" : "liferay",
		"created on" : "'$dateNow'",
		"message" : "'$5'"
	 }'
}

elastic_deleteFromNode () {
	curl -X DELETE "http://$1:$2/$3/testliferaydocument/$4"
}


readFromOneNodeAndDeleteFromAnother(){

	host1=$1
	port1=$2
	host2=$3
	port2=$4
	host3=$5
	port3=$6

	sleep 2
	echo;echo;echo
	echo "first we will create a new empty index for testing purposes" 
	echo "(feel free to change the sharding/replication of this index)"
	sleep 5;
	curl -X PUT "http://$host1:$port1/index1"|json_pp
	curl "http://$host1:$port1/index1/_search"  | json_pp

	echo "write to node $host1:$port1"
	sleep 5;
	elastic_writeToNode $host1 $port1 index1 124 hello | json_pp
	echo;echo;echo
	sleep 2;

	echo "check node $host1:$port1"
	sleep 5;
	curl "http://$host1:$port1/index1/_search"  | json_pp
	echo;echo;echo
	sleep 2;

	echo "check node $host3:$port3"
	sleep 5;
	curl "http://$host3:$port3/index1/_search"  | json_pp
	echo;echo;echo
	sleep 2;

	echo "delete from node $host2:$port2"
	sleep 5;
	elastic_deleteFromNode $host2 $port2 index1 124  | json_pp
	echo;echo;echo
	sleep 2;

	echo "check node $host1:$port1"
	sleep 5;
	curl "http://$host1:$port1/index1/_search"  | json_pp
	echo;echo;echo
	sleep 2;
	
	echo "check node $host2:$port2"
	sleep 5;
	curl "http://$host2:$port2/index1/_search"  | json_pp
	echo;echo;echo
	sleep 2;

	echo "check node $host3:$port3"
	sleep 5;
	curl "http://$host3:$port3/index1/_search"  | json_pp
	echo;echo;echo
	sleep 2;

	echo "delete the index and finish the test"
	sleep 5;
	curl -X DELETE "http://$host1:$port1/index1"

}

if [ "$#" -lt 6 ]; then
    echo
    echo "	Illegal number of parameters"
    echo "	########";echo "	usage:"; echo "	########";echo
    echo "	$0 <host1> <port1> <host2> <port2> <host3> <port3>";echo
    exit 1
fi
readFromOneNodeAndDeleteFromAnother $1 $2 $3 $4 $5 $6

