#!/bin/bash

create_image() {
	cp ../table{snap,slurp,chop} .
	docker build -t tablesnap-test .
	rm table{snap,slurp,chop}
}

start_cluster() {
	# Launch a 3 node cassandra cluster
	docker run --name tablesnap-test1 -d tablesnap-test
	docker run --name tablesnap-test2 -d --link tablesnap-test1:cassandra tablesnap-test
	docker run --name tablesnap-test3 -d --link tablesnap-test1:cassandra tablesnap-test

	echo 'Wait for cluster to come up...'
	docker exec tablesnap-test1 /bin/bash -c 'until nodetool status; do sleep 5; done'
	sleep 5
}

stop_cluster() {
	echo 'Terminating.'
	docker stop tablesnap-test1 tablesnap-test2 tablesnap-test3
	docker rm tablesnap-test1 tablesnap-test2 tablesnap-test3
}

delete_image() {
	docker rmi tablesnap-test
}

shell() {
	docker exec -t -i tablesnap-test1 /bin/bash
}

test_tablesnap() {
	echo 'Inserting test data...'
	docker exec tablesnap-test1 cqlsh -e "CREATE KEYSPACE keyspace1 WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 3 }; USE keyspace1; CREATE TABLE foo (id int PRIMARY KEY, data text); INSERT INTO foo (id,data) VALUES (1, 'bar'); INSERT INTO foo(id,data) VALUES (2,'baz');"

	echo 'Flushing keyspace to create directories...'
	docker exec tablesnap-test1 nodetool flush keyspace1

	echo 'Starting tablesnap...'
	docker exec tablesnap-test1 tablesnap --backup --recursive --auto-add tablesnap-unittest /var/lib/cassandra/data/keyspace1 &
	pid=$!
	sleep 2

	echo 'Triggering compaction...'
	docker exec tablesnap-test1 nodetool compact
	sleep 2

	echo 'Stopping tablesnap...'
	kill $pid

	docker exec tablesnap-test1 test_verify_and_delete.py

	echo 'Using tablechop to clean up...'
	docker exec tablesnap-test1 tablechop tablesnap-unittest /var/lib/cassandra/data/keyspace1 -1
}

case $1 in
	create_image) create_image;;
	start_cluster) start_cluster;;
	stop_cluster) stop_cluster;;
	delete_image) delete_image;;
	shell) shell;;
	test_tablesnap) test_tablesnap;;
	'')
		create_image
		start_cluster
		test_tablesnap
		stop_cluster
		delete_image
		;;
	*) echo "Unknown command.";;
esac
