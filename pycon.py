import tarfile
import shutil
import os

class Args:
    def __init__(self):
        self.master = ''
        self.run = False
args = Args()

def build(pkg,chtcrun='./ChtcRun'):
    """Given a package and a path to a current ChtcRun/ directory tree, execute
    the steps necessary to compile the package for use on condor."""

    # Set variables
    pkg_con = pkg.replace('.tar.gz','.condor.tar.gz')
    slibs = os.path.join(chtcrun,'Pythonin','shared','SLIBS.tar.gz')
    env = os.path.join(chtcrun,'Pythonin','shared','ENV')

    # Copy important python libs and env files to current directory.
    shutil.copy(slibs,'SLIBS_base.tar.gz')
    shutil.copy(env,'ENV')

    # Run chtc_buildPythonmodules
    subprocess.call(
            ['chtc_buildPythonmodules',
                '--pversion=sl6-Python-2.7.7',
                '--pmodules={pkg}'.format(pkg=pkg)])

    # Repackage for use
    with tarfile.open('SLIBS_base.tar.gz','r:gz') as tf:
        tf.extractall()
    with tarfile.open('SLIBS.tar.gz','r:gz') as tf:
        tf.extractall()
    with tarfile.open('SLIBS.tar.gz','w:gz') as tf:
        tf.add('SS')

    print "MODIFIED: SLIBS.tar.gz"

    with tarfile.open(pkg_con,'w:gz') as tf:
        tf.add('SLIBS.tar.gz')
        tf.add('sl6-SITEPACKS.tar.gz')
        tf.add('ENV')

    print "NEW FILE: {pkg_con}".format(pkg_con=pkg_con)

def fixshebang(orig,new=None):
    """Will replace the #! line of an executable python script to point to the
location of the interpreter on remote jobs.
    orig: path to an executable python script to be fixed.
    new: path specifying where a the corrected file should be written to. If
    unspecified, the original file is overwritten."""

    if new is None:
        new = orig

    with open(orig,'r') as f:
        content = f.readlines()

    if content[0][0:2] == '#!':
        content[0] = '#!./python277/bin/python\n'

        with open(new,'w') as f:
            for line in content:
                f.write(line)

    elif not new == orig:
        with open(orig,'r') as of:
            with open(new,'w') as nf:
                shutil.copyfileobj(of, nf)

    os.chmod(new,0755)

def argparse(arglst,pargnames,argtype,flags):
    """ This is a lame substitute for argparse that should bail us out on the
    CHTC submit node where Python 2.6 is used. Probably buggy, definitely
    limited. Excepts a dictionary of arguments paired with keys. The keys will
    be the parameter names, and the arguments themselves are the values.

    How to specify ``flags'':
    flags will be a dictionary where keys are possible flags and values are the
    variable names where the argument values will be stored within the program.
    It is possible for multiple keys to point to the same variable (e.g., to
    support short and long version of the flag).

    How to specify ``argtype'':
    In general, argtype will be a dictionary where keys are variable names
    (e.g., the values in the flags dictionary) and the value will dictate what
    sort of input is expected for that variable. Possible values are:
   -  integer: declares the expected number of inputs associated with that
      flag.
   -  (empty) list: the number of inputs is taken to be > 0 but otherwise
      unbounded. Everything following this flag, up until the next flag, will
      be associated with this variable.
   -  logical (True or False): Indicates that no values are expected to follow
      the flag. The presence of the flag will toggle the value provided in
      ``argtype''. So, if flags={'-a': 'a'} and argtype = {'a': True}, then the
      presence of the -a flag will toggle the True to False.  """
    class ARGS:
        def __init__(self):
            self._type="args"
    args = ARGS()

    # Positional arguments come first. Pair with values and remove them from
    # arglst.
    for name in pargnames:
        setattr(args, name, arglst.pop(0))

    # Parse kwargs
    while len(arglst) > 0:
        flag = arglst.pop(0)
        try:
            arg = flags[flag]
        except KeyError:
            print '\nERROR: {f} is not a known flag\n'.format(f=flag)
            raise KeyError

        if isinstance(argtype[arg],list):
            x = []
            while arglst[0] not in argtype.keys():
                val = arglst.pop(0)
                x.append(val)
        elif isinstance(argtype[arg],int):
            n = argtype[arg]
            x = []
            if n == 1:
                val = arglst.pop(0)
                x = val
            elif n > 1:
                for i in range(n):
                    x.append(arglst.pop(0))
        elif isinstance(argtype[arg],bool):
            x = not argtype[arg]

        setattr(args, arg, x)

    return args

