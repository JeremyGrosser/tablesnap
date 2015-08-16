from setuptools import setup

setup(
    name='tablesnap',
    version='0.7.0',
    author='Jeremy Grosser',
    author_email='jeremy@synack.me',
    scripts=[
        'tablesnap',
        'tableslurp',
        'tablechop'
    ],
    install_requires=[
        x.strip()
        for x in open('requirements.txt').readlines()
        if x and not x.startswith('#')
    ],
)
