from setuptools import setup

setup(
    name='tablesnap',
    version='0.4.0',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    scripts=['tablesnap'],
    install_requires=[
        'pyinotify',
        'boto',
    ]
)
