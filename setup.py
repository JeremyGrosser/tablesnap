from setuptools import setup

setup(
    name='tablesnap',
    version='0.1',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    scripts=['tablesnap'],
    install_requires=[
        'pyinotify',
        'boto',
    ]
)
