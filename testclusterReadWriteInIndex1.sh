#!/usr/bin/env bash

readFromOneNodeAndDeleteFromAnother(){
	source ./commands.sh 

	echo "write to node $1:"
	elastic_writeToNode $1 index1 124 "hello world"
	sleep 2;

	echo "\ncheck node $1:"
	curl "http://localhost:$1/index1/_search"  | json_pp
	sleep 2;

	echo "\ncheck node $2:"
	curl "http://localhost:$2/index1/_search"  | json_pp
	sleep 2;

	echo "\n\n\ndelete from node $2:"
	elastic_deleteFromNode $2 index1 124 
	sleep 2;

	echo "\ncheck node $1:"
	curl "http://localhost:$1/index1/_search"  | json_pp
	sleep 2;
	
	echo "\ncheck node $2:"
	curl "http://localhost:$2/index1/_search"  | json_pp
	sleep 2;

	echo "\ncheck node $3:"
	curl "http://localhost:$3/index1/_search"  | json_pp
	sleep 2;

}

readFromOneNodeAndDeleteFromAnother 9200 9201 9202

