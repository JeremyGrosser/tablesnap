Tablesnap
=========

Theory of Operation
-------------------

Tablesnap is a script that uses inotify to monitor a directory for `IN_MOVED_TO`
events and reacts to them by spawning a new thread to upload that file to
Amazon S3, along with a JSON-formatted list of what other files were in the
directory at the time of the copy.

When running a Cassandra cluster, this behavior can be quite useful as it
allows for automated point-in-time backups of SSTables. Theoretically,
tablesnap should work for any application where files are written to some
temporary location, then moved into their final location once the data is
written to disk. Tablesnap also makes the assumption that files are immutable
once written.

Installation
------------

This distribution provides a debian/ source directory, allowing it to be built
as a standard Debian/Ubuntu package and stored in a repository. The Debian
package includes an init script that can run and daemonize tablesnap for you.
Tablesnap does not daemonize itself. This is best left to tools like
init, supervisord, daemontools, etc.

There are pre-build binaries for Ubuntu Maverick amd64 and i386 in this PPA:
<https://launchpad.net/~synack/+archive/tablesnap>

	# cat /etc/apt/sources.list.d/tablesnap.list << EOF
	> deb http://ppa.launchpad.net/synack/tablesnap/ubuntu maverick main
	> deb-src http://ppa.launchpad.net/synack/tablesnap/ubuntu maverick main
	> EOF
	# aptitude update

The daemonized version of the Debian/Ubuntu package uses syslog for logging.
The messages are sent to the `DAEMON` logging facility and tagged with
`tablesnap`. If you want to redirect the log output to a log file other than
`/var/log/daemon.log` you can filter by this tag. E.g. if you are using
syslog-ng you could add

```
# tablesnap
filter f_tablesnap { filter(f_daemon) and match("tablesnap" value("PROGRAM")); };
destination d_tablesnap { file("/var/log/tablesnap.log"); };
log { source(s_src); filter(f_tablesnap); destination(d_tablesnap); flags(final); };
```

to `/etc/syslog-ng/syslog-ng.conf`.

If you are not a Debian/Ubuntu user or do not wish to install the tablesnap
package, you may copy the tablesnap script anywhere you'd like and run it from
there. Tablesnap depends on the pyinotify and boto Python packages. These are
available via "pip install pyinotify; pip install boto;", or as packages from
most common Linux distributions.

Configuration
-------------

All configuration for tablesnap happens on the command line. If you are using
the Debian package, you'll set these options in the `DAEMON_OPTS` variable in
`/etc/default/tablesnap`.

```
usage: tablesnap [-h] -k AWS_KEY -s AWS_SECRET [-r] [-a] [-B] [-p PREFIX]
                 [--without-index] [--keyname-separator KEYNAME_SEPARATOR]
                 [-t THREADS] [-n NAME] [-e EXCLUDE | -i INCLUDE]
                 [--listen-events {IN_MOVED_TO,IN_CLOSE_WRITE}]
                 [--max-upload-size MAX_UPLOAD_SIZE]
                 [--multipart-chunk-size MULTIPART_CHUNK_SIZE]
                 bucket paths [paths ...]

Tablesnap is a script that uses inotify to monitor a directory for events and
reacts to them by spawning a new thread to upload that file to Amazon S3,
along with a JSON-formatted list of what other files were in the directory at
the time of the copy.

positional arguments:
  bucket                S3 bucket
  paths                 Paths to be watched

optional arguments:
  -h, --help            show this help message and exit
  -k AWS_KEY, --aws-key AWS_KEY
  -s AWS_SECRET, --aws-secret AWS_SECRET
  -r, --recursive       Recursively watch the given path(s)s for new SSTables
  -a, --auto-add        Automatically start watching new subdirectories within
                        path(s)
  -B, --backup          Backup existing files to S3 if they are not already
                        there
  -p PREFIX, --prefix PREFIX
                        Set a string prefix for uploaded files in S3
  --without-index       Do not store a JSON representation of the current
                        directory listing in S3 when uploading a file to S3.
  --keyname-separator KEYNAME_SEPARATOR
                        Separator for the keyname between name and path.
  -t THREADS, --threads THREADS
                        Number of writer threads
  -n NAME, --name NAME  Use this name instead of the FQDN to identify the
                        files from this host
  -e EXCLUDE, --exclude EXCLUDE
                        Exclude files matching this regular expression from
                        upload.WARNING: If neither exclude nor include are
                        defined, then all files matching "-tmp" are excluded.
  -i INCLUDE, --include INCLUDE
                        Include only files matching this regular expression
                        into upload.WARNING: If neither exclude nor include
                        are defined, then all files matching "-tmp" are
                        excluded.
  --listen-events {IN_MOVED_TO,IN_CLOSE_WRITE}
                        Which events to listen on, can be specified multiple
                        times. Values: IN_MOVED_TO (default), IN_CLOSE_WRITE
  --max-upload-size MAX_UPLOAD_SIZE
                        Max size for files to be uploaded before doing
                        multipart (default 5120M)
  --multipart-chunk-size MULTIPART_CHUNK_SIZE
                        Chunk size for multipart uploads (default: 256M or 10%
                        of free memory if default is not available)
```

For example:

	$ tablesnap -k AAAAAAAAAAAAAAAA -s BBBBBBBBBBBBBBBB me.synack.sstables /var/lib/cassandra/data/GiantKeyspace

This would cause tablesnap to use the given Amazon Web Services credentials to
backup the SSTables for my `GiantKeyspace` to the S3 bucket named
`me.synack.sstables`.

Questions, Comments, and Help
-----------------------------
The fine folks in `#cassandra-ops` on `irc.freenode.net` are an excellent
resource for getting tablesnap up and running, and also for solving more
general Cassandra issues.
