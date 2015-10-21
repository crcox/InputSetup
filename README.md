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

expandStub_yaml.py
-------------
This program allows you to take a yaml "stub file" such as:

```yaml
# stub.yaml
A: 1
B: 2
C: [1,2]
D: [3,4]
E: [1,2,3]
F: [7,8,9]
ExpandFields:
    - [C,D]
    - E
```

into:

```yaml
# master.json
--- A: 1 B: 2 C: 1 D: 3 E: 1 F: [7, 8, 9]
--- A: 1 B: 2 C: 2 D: 4 E: 1 F: [7, 8, 9]
--- A: 1 B: 2 C: 1 D: 3 E: 2 F: [7, 8, 9]
--- A: 1 B: 2 C: 2 D: 4 E: 2 F: [7, 8, 9]
--- A: 1 B: 2 C: 1 D: 3 E: 3 F: [7, 8, 9]
--- A: 1 B: 2 C: 2 D: 4 E: 3 F: [7, 8, 9]
```

using:

`./expandStub_yaml.py stub.yaml`

In `stub.yaml`, I am specifying a scheme that involves several parameters. I am saying: "For all jobs, `A=1` and `B=2`, and `F=[7,8,9]`. Each job will get additionally some combination of `C`, `D`, and `E`, and that is defined by the (cryptic) `ExpandFields` special parameter.  In particular, `C` and `D` are linked such that some jobs will get `C=1` and `D=3`, while others will get `C=2` and `D=4`. `E` is not linked with anything, so it should be crossed with `[C,D]` (which are linked, and so can be considered as a set)".

setupJobs_yaml.py
-----------
This script simply translates the `master.yaml` file produced by
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
