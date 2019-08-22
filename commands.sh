#!/usr/bin/env bash

#curl "http://localhost:9200/_cluster/health"  | json_pp
elastic_fixCluster(){
	curl -X PUT "http://localhost:9200/_settings" -H 'Content-Type: application/json' -d'
		{ "index": { "blocks": { "read_only_allow_delete": "false" } } }'
}

elastic_fixIndex(){ 
	curl -X PUT "http://localhost:9200/$1/_settings" -H 'Content-Type: application/json' -d'
		{ "index.routing.allocation.exclude._name": null }'
	curl -X PUT "http://localhost:9200/$1/_settings" -H 'Content-Type: application/json' -d'
		{ "index": { "blocks": { "read_only_allow_delete": "false" } } }'
	
}

elastic_fixWatermarks(){
	curl -X PUT "localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
	{
  	"transient": {
    		"cluster.routing.allocation.disk.watermark.low": "2gb",
    		"cluster.routing.allocation.disk.watermark.high": "1gb",
    		"cluster.routing.allocation.disk.watermark.flood_stage": "500mb",
    		"cluster.info.update.interval": "1m"
  		}
	}'
}





elastic_allocateshards(){
	curl -X POST 'http://localhost:$1/_cluster/reroute' -H 'Content-Type: application/json' -d' 
	{ "commands" : [ { "allocate" : { "index" : "constant-updates", "shard" : 0, "node": "$2", "allow_primary": "true" } }] }'
}

elastic_checkNodes(){ curl "http://localhost:$1/_cat/nodes?v" }
elastic_checkIndices(){ curl "http://localhost:$1/_cat/indices?v" }
elastic_checkIndex(){ curl "http://localhost:$1/$2" | json_pp }
elastic_checkShards(){ 
	echo "allocation/explain:\n" && curl "http://localhost:9200/_cluster/allocation/explain"  | json_pp
	curl -s 'http://localhost:9200/_cat/allocation?v'
	curl "http://localhost:9200/_cat/shards?h=index,shard,prirep,state,node,unassigned.reason" 
	curl "http://localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason" | grep UNASSIGNED 
}




elastic_createIndexDefaults(){ curl -X PUT "localhost:$1/$2" }
elastic_createIndex(){ 
	curl -X PUT "localhost:$1/$2" -H 'Content-Type: application/json' -d'
	{
    		"settings" : {
        		"index" : {
            			"number_of_shards" : 2,
            			"number_of_replicas" : 2
        		}
    		}
	}
	'

	curl -X PUT "localhost:$1/_cluster/settings" -H 'Content-Type: application/json' -d' { "transient": { "discovery.zen.minimum_master_nodes": 2 } } '


}

elastic_writeToNode(){ 
	dateNow="$(date +"%Y-%m-%dT%T.%3N")"
	curl -X PUT "http://localhost:$1/$2/liferaydocument/$3" -H 'Content-Type: application/json' -d'
	{
		"user" : "carlos",
		"created on" : "'$dateNow'",
		"message" : "'$4'"
	 }' | json_pp
}

elastic_deleteFromNode(){ 
	echo 'curl -X DELETE "http://localhost:'$1'/'$2'/liferaydocument/'$3'"'
	curl -X DELETE "http://localhost:$1/$2/liferaydocument/$3" | json_pp
}

elastic_enableReallocation(){ 
	curl -X PUT "http://localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d '{ "transient": { "cluster.routing.allocation.enable" : "all" } }'
}
