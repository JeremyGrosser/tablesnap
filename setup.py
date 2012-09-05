from setuptools import setup

setup(
    name='tablesnap',
    version='0.5',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    scripts=['tablesnap', 'tableslurp'],
    install_requires=[
        'pyinotify',
        'boto>=2.2',
    ]
)
