FROM cassandra:3.11
RUN apt-get update && apt-get install -y python3-pyinotify python3-boto python3-dateutil python3-eventlet
ADD boto.cfg /etc/
ADD tablesnap tableslurp tablechop test_verify_and_delete.py /usr/local/bin/
