Condor Tools
================
This repository is a collection of small programs that support setting
up and administrating jobs on condor/chtc submit nodes.

Analysis Protocol
-----------------
See how I set up jobs for dispatch on HTCondor here:

https://gist.github.com/crcox/899e27a56a0c7f1126bf

Installation
-------------
`./setup.py`

This handled the installation of `pycon`, a set of libraries that aid
setting up batches of jobs for HTCondor. The python script `setupJobs`
is also installed so that there is a ready interface to these libraries
from the command line.

To install `pycon` issue the following at the command line from within
the `condortools` directory. Any time a new version of the code is
downloaded, you will need to re-issue this command if you want to update
the installed version of the code. This should handle installing
dependencies as well.

```bash
python ./setup.py install --user
```

Dependencies
------------
This set of tools has a number of Python dependencies. Depending on your
environment, you may need to manage these dependencies at the user level
(as opposed to the system level). For guides on how to administer Python
in one such restricted environment (a HTCondor submit node maintained by
the CHTC at University of Wisconsin-Madison), see the following two
link. N.B. The `./setup.py` process may do everything properly, and if
so you will not have to worry about this.

- [Administering Python on the Submit Node](https://gist.github.com/crcox/2fda1ed0d2766cd992d1)

Once you are setup to install modules locally and have ensured these
local directories are on all relevant paths, the following modules need
to be installed. Again, if ./setup.py worked propperly, you will not
need to do this manually.

### Python Modules

```{bash}
pip install pyyaml --user
pip install mako --user
```

PyCon and setupJobs
===================
This program allows you to take a yaml "stub file" such as:

```yaml
# stub.yaml
A: 1
B: 2
C: [1,2]
D: [3,4]
E: [1,2,3]
F: [7,8,9]
EXPAND:
    - [C,D]
    - E
COPY: []
URLS: []
```

and use it as a guide to set up many independent jobs that can be
launched using HTCondor. Given the `stub.yaml` file defined above:

```bash
setupJobs stub.yaml
```

will yield:

`0/params.json`
```json
A: 1, B: 2, C: 1, D: 3, E: 1, F: [7, 8, 9]
```
`1/params.json`
```json
A: 1, B: 2, C: 2, D: 4, E: 1, F: [7, 8, 9]
```
`2/params.json`
```json
A: 1, B: 2, C: 1, D: 3, E: 2, F: [7, 8, 9]
```
`3/params.json`
```json
A: 1, B: 2, C: 2, D: 4, E: 2, F: [7, 8, 9]
```
`4/params.json`
```json
A: 1, B: 2, C: 1, D: 3, E: 3, F: [7, 8, 9]
```
`5/params.json`
```json
A: 1, B: 2, C: 2, D: 4, E: 3, F: [7, 8, 9]
```

In `stub.yaml`, I am specifying a scheme that involves several
parameters. I am saying: "For all jobs, `A=1` and `B=2`, and
`F=[7,8,9]`. Each job will additionally get some combination of `C`,
`D`, and `E`, and that is defined by the `EXPAND` special
parameter.  In particular, `C` and `D` are linked such that some jobs
will get `C=1` and `D=3`, while others will get `C=2` and `D=4`.  `E` is
not linked with anything, so it should be crossed with `[C,D]` (which
are linked, and so can be considered as a set)".

`setupJobs` can also setup DAG and Submit files for each job and the
batch of jobs overall, given just a little more information.

```bash
setupJobs -d process.yaml stub.yaml
```

Where `process.yaml` is based on the following template:

```
# Specify in KB, MB, or GB.
# No space between numbers and letters.
request_memory: "2GB"
request_disk: "10GB"

# If your jobs are less than 4 hours long, "flock" them additionally to
# other HTCondor pools on campus.
# If your jobs are less than ~2 hours long, "glide" them to the national
# Open Science Grid (OSG) for access to even more computers and the
# fastest overall throughput.
FLOCK: "true"
GLIDE: "false"

SHAREDIR: "../shared"

# The WRAPPER is what will actually be run by condor. The path you enter
# here will be inserted directly into the submit file, and so should be
# defined relative to the position of a submit file. Typically, this
# means: back out of a job-specific folder, enter the share folder, and
# name the wrapper, as in ../shared/wrapper.sh
WRAPPER: "../shared/run_WholeBrain_RSA.sh"

# The EXECUTABLE is the name of the file that the WRAPPER will execute.
# By the time the WRAPPER is executing, you will be on the execute node
# and so the EXECUTABLE and the WRAPPER will be in the same location.
# Therefore, you should just specify the basename of the EXECUTABLE here.
EXECUTABLE: "WholeBrain_RSA_beta" # path relative to execute node.

# If the EXECUTABLE is written to accept command line arguments, they
# can be specified here. Positional arguments should be specified under
# execPArgs, and named arguments should be assigned using key: value pairs
# under execKVArgs.
execPArgs:
  #  - 1
  #  - 2
execKVArgs:
  #foo: bar
```

If you are dispatching jobs using HTCondor, then many file paths need to
be updated within the individual `params.json` files. This is because
the HTCondor will deliver all files to a job into a single directory.
The file paths in `params.json`, therefore, should be truncated to
basenames. To have setupJobs do this for you, add the `-l` flag. Do
_NOT_ do this if you are running jobs locally on your own machine.

```bash
setupJobs -d process.yaml stub.yaml
```


SubmitNodeTools
===============
cox_submit_dag.sh and lsdag.sh
------------------------------
These batch scripts, if you choose to use them (and it's only fair to say they are very beta at this point), should be installed on your path, and you'll probably want to strip the .sh. cox_submit_dag is a thin wrapper around condor_submit_dag that simply appends a line to a log file in your home directory called `.activedags`, and allows you to add a label to the DAG. So instead of:

```
condor_submit_dag sweep.dag
```

You would run:
```
cox_submit_dag sweep.dag "16 character lab" # 16 might be too short after all...
```

This file is referenced by `lsdag` when parsing `condor_q` for information about your DAGs and active jobs. lsdag serves as an alternative to `condor_q` if you just want a high level summary of everything you have going on. `lsdag` currently takes no arguments.

```
> lsdag
Active DAGs:
      ID           Label    Idle  Active    Hold   NJobs    Done     Pct
 5839062      GrOWL2 vis       2      29       0   16560   16506   99.67%
 5848962        L1L2 sem      53    1763       4    3518     669   19.02%
 5849090       GrOWL sem       6     153       3    3518    2408   68.45%

Finished DAGs
```

LocalTools
==========
addCHTCtoHostsList.sh
---------------------
This script is indended to be run on your own computer to make it easier
to connect to the chtc submit node. On your local machine, run:

`sudo ./addCHTCtoHostsList.sh`

After executing this script, you will be able to connect to the submit
node with:

`ssh <username>@chtc`

ExecuteNodeTools
================
packageForShipping.py
---------------------
This script should be sent out with every job as a post-script. It has a
single, simple function: to store any directories produced by the job on
the remote machine in a compressed archive that condor will return to
the submit node. Without this post script, any data written out into a
directory structure of folders will be _left behind_.

Coming soon: instructions on how to include this script with your jobs.
