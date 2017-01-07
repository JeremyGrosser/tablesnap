from setuptools import setup

setup(
    name='tablesnap',
    version='1.0.0',
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
)
