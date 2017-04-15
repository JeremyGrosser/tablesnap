#!/usr/bin/env python
import boto
import sys


def main():
    s3 = boto.connect_s3()
    bucket = s3.get_bucket('tablesnap-unittest')
    keys = bucket.get_all_keys()

    if not keys:
        print 'TEST FAIL No keys found in test bucket!'
        return 1
    else:
        print 'TEST PASS Tablesnap created S3 keys successfully!'

    #bucket.delete_keys(keys)
    return 0


if __name__ == '__main__':
    sys.exit(main())
