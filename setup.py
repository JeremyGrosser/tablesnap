from setuptools import setup

setup(
    name='tablesnap',
    description='Uses inotify to monitor Cassandra SSTables and upload them to S3',
    long_description='Tablesnap is a script that uses inotify to monitor a directory for IN_MOVED_TO events and reacts to them by spawning a new thread to upload that file to Amazon S3, along with a JSON-formatted list of what other files were in the directory at the time of the copy.',
    version='1.0.3',
    license='BSD',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    url='https://github.com/JeremyGrosser/tablesnap',
    scripts=[
        'tablesnap',
        'tableslurp',
        'tablechop'
    ],
    install_requires=[
        'pyinotify',
        'boto>=2.6.0',
        'argparse',
        'python-dateutil',
    ],
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python',
        'Topic :: Database',
        'Topic :: System :: Archiving :: Backup',
        'Topic :: Utilities',
    ]
)
