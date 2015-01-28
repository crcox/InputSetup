Condor Tools
================
This repository is a collection of small programs that support setting
up and administrating jobs on condor/chtc submit nodes.

Installation
-------------
`./install`

This is an extremely simple script that will copy the executable scripts
in this repo into ~/bin, and any python modules into
~/.local/lib/python2.6/site-packages. This will immediately make the
python modules available to any script that depends on it that runs on
the submit node itself. If for any reason a python module needs to be
run on a remote job machine, it will need to be compiled and dispatched
along with the job. To ensure access to the  executable scripts in
~/bin, add:

`export PATH=${PATH}:~/bin`

to your .bashrc (or .zshrc, as the case may be).

addCHTCtoHostsList.sh
---------------------
This script is indended to be run on your own computer to make it easier
to connect to the chtc submit node. On your local machine, run:

`sudo ./addCHTCtoHostsList.sh`

After executing this script, you will be able to connect to the submit
node with:

`ssh <username>@chtc`

expandStub.py
-------------
This program allows you to take a json "stub file" such as:

```json
# stub.json
{
  "x": [1,2,3],
  "y": ["a","b"],
  "z": 9001
}
```

into:

```json
# master.json
{
  "x": [1,2,3],
  "y": ["a","b"],
  "z": 9001,
  "configs": [
    {
      "x": 1,
      "y": "a"
    },
    {
      "x": 2,
      "y": "a"
    },
    {
      "x": 3,
      "y": "b"
    },
    {
      "x": 1,
      "y": "b"
    },
    {
      "x": 2,
      "y": "b"
    },
    {
      "x": 3,
      "y": "b"
    }
  ]
}
```

using:

`./expandStub.py stub.json -k x y`

The values after the `-k` indicate which fields need to be expanded
across individual configurations. Each one of these configurations will
be associated with an independent job that we will dispatch to the
cluster. The output is a new json file, `master.json`.

setupJobs.py
-----------
This script simply translates the `master.json` file produced by
`expandStub.py` into a series of folders, each with their own config
file. Currently, this script is rather project specific, but there are
core features that may be extracted into a function in the `pycon`
module. Each project will then have its own setup script.

packageForShipping.py
---------------------
This script should be sent out with every job as a post-script. It has a
single, simple function: to store any directories produced by the job on
the remote machine in a compressed archive that condor will return to
the submit node. Without this post script, any data written out into a
directory structure of folders will be _left behind_.

Coming soon: instructions on how to include this script with your jobs.

PyCon
=====
A python module with utilities for everything from compiling python code
for use on condor to fixing the "shebang" (#!) lines in executable
scripts used on the submit node. These functions are intended for use
inside project-specific code, and (should?) have usage information in
the source code.
executable python files
