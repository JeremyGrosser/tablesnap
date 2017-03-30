FROM cassandra:2.2
RUN apt-get update && apt-get install -y python-pyinotify python-boto python-argparse python-dateutil python-eventlet
ADD boto.cfg /etc/
ADD tablesnap tableslurp tablechop test_verify_and_delete.py /usr/local/bin/
