#!/usr/bin/env python
import subprocess
import yaml
import json
import os
import sys
import shutil
import argparse
p = argparse.ArgumentParser()
p.add_argument('master')
p.add_argument('-s','--setup_submitfile',action='store_true')
p.add_argument('-d','--setup_dags',action='store_true')
args = p.parse_args()

PERLBIN = os.path.join(os.path.expanduser('~'),'src','condortools')
PERLTEMPLATES = os.path.join(os.path.expanduser('~'),'src','condortools','templates')

#############################################################
#   Load data and parameters from the "master" json file    #
#############################################################
yamlfile = args.master
with open(yamlfile,'rb') as f:
    ydat = list(yaml.load_all(f))

#############################################################
#  Define a root folder (current directory if not a condor  #
#                           run)                            #
#############################################################
assert 'environment' in ydat[0]
ref = ydat[0]['environment']
same = [ref==ydat[i]['environment'] for i in xrange(len(ydat))]
assert all(same)
if all(same):
    sharedenv = ref

if sharedenv == 'condor':
    rootdir = '.'
else:
    rootdir = '.'

#############################################################
#                 Setup directory structure                 #
#############################################################
sharedir = os.path.join(rootdir,'shared')
if not os.path.isdir(sharedir):
    os.makedirs(sharedir)

#############################################################
#            Copy shared binary files into place            #
#############################################################
if sharedenv == 'condor':
    assert 'executable' in ydat[0]
    ref = ydat[0]['executable']
    same = [ref==ydat[i]['executable'] for i in xrange(len(ydat))]
    assert all(same)
    if all(same):
        sharedexe = ref
        sharedexe_copy = os.path.join(sharedir,os.path.basename(sharedexe))
        shutil.copyfile(sharedexe, sharedexe_copy)

#############################################################
#                    Write URLS files                       #
#############################################################
if sharedenv == 'condor':
    print """
    NB: In the condor environment, all data should be hosted on SQUID.
    These paths are assumed to be pointing to SQUID. However, the /squid is
    implied and so can be excluded. (e.g., instead of /squid/crcox, use just
    /crcox.)
    """
    if isinstance(ydat[0]['URLS'],list):
        toURL = ydat[0]['URLS']
    else:
        toURL = [ydat[0]['URLS']]

    SharedURLS = []
    for field in toURL:
        ref = ydat[0][field]
        DataAreSame = [ref==ydat[i][field] for i in xrange(len(ydat))]
        if all(DataAreSame):
            shareddata = ref

        if all(DataAreSame):
            if isinstance(shareddata,list):
                SharedURLS.extend(shareddata)
            else:
                SharedURLS.append(shareddata)

        else:
            for i in xrange(len(ydat)):
                jobdir = os.path.join(rootdir, "{job:03d}".format(job=i))
                if not os.path.isdir(jobdir):
                    os.makedirs(jobdir)
                URLS = os.path.join(jobdir,'URLS')
                with open(URLS,'w') as f:
                    data = ydat[i][field]
                    if isinstance(data,list):
                        for d in data:
                            f.write(d+'\n')
                    else:
                        f.write(data+'\n')

        # Modify the data paths to point to a local data directory rather than
        # the squid proxy server. This will allow data to be loaded on the
        # machine.
        for i in xrange(len(ydat)):
            data = ydat[i][field]
            if isinstance(data,list):
                if len(data) > 1:
                    for ii,d in enumerate(data):
                        dmod = os.path.basename(d)
                        ydat[i][field][ii] = dmod
                else:
                    dmod = os.path.basename(data[0])
                    ydat[i][field] = dmod

            else:
                dmod = os.path.basename(data)
                ydat[i][field] = dmod

    if SharedURLS:
        URLS = os.path.join(sharedir,'URLS_SHARED')
        with open(URLS,'w') as f:
            f.write('\n'.join(SharedURLS))

#############################################################
#           Distribute params.json file to each job         #
#############################################################
for i, cfg in enumerate(ydat):
    jobdir = os.path.join(rootdir, "{job:03d}".format(job=i))
    if not os.path.isdir(jobdir):
        os.makedirs(jobdir)
    paramfile = os.path.join(jobdir,'params.json')
    with open(paramfile, 'w') as f:
        json.dump(cfg, f, sort_keys = True, indent = 4)

#############################################################
#          Perform other optional setup operations          #
#############################################################
if args.setup_dags:
    FillDAGTemplate = [
            os.path.join(PERLBIN,'FillDAGTemplate.pl'),
            os.path.join(PERLTEMPLATES,'subdag.template'),
            str(len(ydat))]
    subprocess.call(FillDAGTemplate)

if args.setup_submitfile:
    FillProcessTemplate = [
            os.path.join(PERLBIN,'FillProcessTemplate.pl'),
            os.path.join(PERLTEMPLATES,'process.template'),
            str(len(ydat)),
            os.path.join('process.yaml')]
    subprocess.call(FillProcessTemplate)
