#!/usr/bin/env python

""" Cleans SSTables on S3 """

import argparse
import boto
import json
import logging
import os
import socket
import sys

from datetime import datetime
from dateutil import parser as dtparser

now = None

def days_ago(tstamp):
    global now
    if now is None:
        now = datetime.now()
    # Datetime format from the last_modified property on keys from boto
    backup = datetime.strptime(tstamp, '%Y-%m-%dT%H:%M:%S.%fZ')
    delta = now - backup
    return delta.days

def clean_backups(args, log):

    if args.debug:
        log.setLevel(logging.DEBUG)

    if not args.name:
        args.name = socket.getfqdn()

    try:
        s3conn = boto.connect_s3(args.key, args.secret)
        bucket = s3conn.get_bucket(args.bucket)
    except boto.exception.BotoServerError, e:
        log.error('Problem initializing S3 connection: %s', e)
        sys.exit(1)

    try:
        key_list = bucket.list("%s:%s" % (args.name, args.path))
    except boto.exception.BotoServerError, e:
        log.error('Problem getting keys from S3 bucket: %s', e)
        sys.exit(1)

    log.info("Connected to S3, getting keys ...")

    json_keys = []
    to_delete = set() # we'll remove from this list
    for k in sorted(
        key_list,
        key=lambda k: dtparser.parse(k.last_modified),
        reverse=True, # most recent first
    ):
        to_delete.add(k.name)
        if k.name.endswith('-listdir.json'):
            json_keys.append(k)

    log.info("%s keys total", len(to_delete))
    log.debug("%s json listdir keys", len(json_keys))

    for jkey in json_keys:
        log.debug("key dated : %s (%s)", jkey.last_modified,
                  jkey.name.split('/')[-1])
        if days_ago(jkey.last_modified) > args.age:
            # We've gone back past our cutoff
            log.info("reached cutoff at timestamp %s", jkey.last_modified)
            break
        ky = bucket.get_key(jkey)
        jdict = json.loads(ky.get_contents_as_string())
        if len(jdict.values()) != 1:
            raise SystemError('-listdir.json file should have '
                'a single key/value pair!')
        dirname = jdict.keys()[0]
        # fullpaths here since some files are in subdirectories
        fullpaths = [os.path.join(dirname, x) for x in jdict.values()[0]]
        for x in fullpaths:
            key_to_keep = '%s:%s' % (args.name, x)
            if key_to_keep in to_delete:
                to_delete.remove(key_to_keep)
        if jkey.name in to_delete:
            to_delete.remove(jkey.name)

    if args.debug:
        log.debug("%s non-keeper keys to delete", len(to_delete))
        ddates = list(set([x.last_modified[:10] for x in key_list \
                           if x.name in to_delete]))
        ddates.sort()
        log.debug("deletion dates : %s", ddates)
        log.debug("Test mode, nothing deleted")
        return

    log.info("Deleting %s keys", len(to_delete))

    try:
        bucket.delete_keys(to_delete) # !!
    except Exception as e:
        log.error('S3 delete ERR, will try again later [%s]', e)

    log.info("Keys deleted")

def main(log):
    parser = argparse.ArgumentParser(
        description='Clean SSTables from S3. Scroll backwards through '
        '-listdir.json keys in chronological order collecting a "keeper" '
        'list until it reaches it\'s age cutoff. Deletes all keys not in that '
        'list')
    parser.add_argument(
        '-d',
        '--debug',
        dest='debug',
        action='store_true',
        help='Run in debug mode, will not delete keys. Implies -v')
    parser.add_argument(
        '-k',
        '--key',
        required=True,
        dest='key',
        help='Amazon S3 Key')
    parser.add_argument(
        '-s',
        '--secret',
        required=True,
        dest='secret',
        help='Amazon S3 Secret')
    parser.add_argument(
        '-n',
        '--name',
        dest='name',
        required=False,
        help='Use this name instead of the FQDN to identify the files from '
             'this host')
    parser.add_argument(
        'bucket',
        help='S3 Bucket')
    parser.add_argument(
        'path',
        help='Path portion of key in S3')
    parser.add_argument(
        'age',
        type=int,
        help='How many days worth of backups to keep')
    args = parser.parse_args()
    clean_backups(args, log)

if __name__ == '__main__':

    log = logging.getLogger('tablechop')
    stderr = logging.StreamHandler()
    stderr.setFormatter(logging.Formatter(
        '%(name)s [%(asctime)s] %(levelname)s %(message)s'))
    log.addHandler(stderr)
    if os.environ.get('TDEBUG', False):
        log.setLevel(logging.DEBUG)
    else:
        log.setLevel(logging.INFO)

    main(log)
