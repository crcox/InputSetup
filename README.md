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

Dependencies
------------
This set of tools has a number of Python and Perl dependencies. Depending on your environment, you may need to manage these dependencies at the user level (as opposed to the system level). For guides on how to administer Python and Perl in one such restricted environment (a HTCondor submit node maintained by the CHTC at University of Wisconsin-Madison), see the following two links:

- [Administering Python on the Submit Node](https://gist.github.com/crcox/2fda1ed0d2766cd992d1)
- [Administering Perl on the Submit Node](https://gist.github.com/crcox/da0d36e05b66cbec3f73)

Once you are setup to install modules locally and have ensured these local directories are on all relevant paths, the following modules need to be installed:

### Python Modules

```{bash}
pip install pyyaml --user
```
### Perl Modules

```{bash}
cpanm Text::Template
cpanm YAML::XS
cpanm String::Scanf
cpanm Path::Tiny
```

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
--- A: 1, B: 2, C: 1, D: 3, E: 1, F: [7, 8, 9]
--- A: 1, B: 2, C: 2, D: 4, E: 1, F: [7, 8, 9]
--- A: 1, B: 2, C: 1, D: 3, E: 2, F: [7, 8, 9]
--- A: 1, B: 2, C: 2, D: 4, E: 2, F: [7, 8, 9]
--- A: 1, B: 2, C: 1, D: 3, E: 3, F: [7, 8, 9]
--- A: 1, B: 2, C: 2, D: 4, E: 3, F: [7, 8, 9]
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
