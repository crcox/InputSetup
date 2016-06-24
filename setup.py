import os
from setuptools import setup

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "condortools",
    version = "0.0.1",
    author = "Chris Cox",
    author_email = "cox.crc@gmail.com",
    description = ("Collection of simple tools useful for working with HTCondor."),
    license = "MIT",
    keywords = "HTCondor UW-Madison",
    url = "http://packages.python.org/nextmds",
    packages=['pycon'],
    scripts = ['setupJobs','quickstub'],
    long_description=read('README.md'),
    install_requires=[
                  'pyyaml',
                  'mako'
    ],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
    ],
)
