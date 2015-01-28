import tarfile
import shutil
import os

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
        with open(orig,'r'), open(new,'w') as of,nf:
            shutil.copyfileobj(of, nf)

    os.chmod(new,0755)
