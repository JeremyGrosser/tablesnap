from setuptools import setup

setup(
    name='tablesnap',
    version='0.6.0',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    scripts=['tablesnap', 'tableslurp'],
    install_requires=[
        'pyinotify',
        'boto>=2.2',
        'argparse',
    ]
)
