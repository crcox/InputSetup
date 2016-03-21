#!/usr/bin/env python
import argparse
import json
import os
import pycon
import pycon.utils
import shutil
import subprocess
import yaml

p = argparse.ArgumentParser()
# Required Positional Arguments
p.add_argument('stub')
# Flags
p.add_argument('-d','--setup_dags',action='store_true')
p.add_argument('-l','--local_data',action='store_true')
p.add_argument('-s','--setup_submitfile',action='store_true')
# Options
p.add_argument('-o','--offset_index',type=int,nargs=1,default=0,help='Number of the first directory to affect/create. Intended to help add jobs to an existing set.')
p.add_argument('-r','--root_dir',type=str,nargs=1,default='.',help='Directory in which job directories will be constructed.')

args = p.parse_args()

## This is sort of a hack. If condortools is installed somewhere else, the code
## below will need to be changed.
PERLBIN = os.path.join(os.path.expanduser('~'),'src','condortools')
PERLTEMPLATES = os.path.join(os.path.expanduser('~'),'src','condortools','templates')

STUBYAML = args.stub
OFFSET = args.offset_index
ROOTDIR = args.root_dir

FLAG_LOCALDATA = args.local_data
FLAG_SETUPDAG = args.setup_dags
FLAG_SETUPSUBMIT = args.setup_submitfile

SPECIALFIELDS = ['ExpandFields','URLS','COPY']
StubAsMaster = False

with open(STUBYAML,'rb') as f:
    stub = list(yaml.load_all(f))

try:
    EXPAND = stub['ExpandFields']
except KeyError:
    print "Stub does not include an ExpandFields list. Treating stub as master..."
    StubAsMaster = True

sharedir = os.path.join(ROOTDIR,'shared')
if not os.path.isdir(sharedir):
    os.makedirs(sharedir)

#############################################################
#         Copy files to be shared into ./shared             #
#############################################################
# After copying, the file path is updated so that the
# executable will reference the copied version of the file. If
# FLAG_LOCALDATA is True, then the path will be set to look
# for the file in the job's current directory. This is for jobs
# that run on HTCondor, since all files are transfered into the
# job directory (directories themselves are not transfered).
COPY_shared = [field for field in stub['COPY'] if field not in EXPAND]
for field in COPY_shared:
    source = stub[field]
    if isinstance(stub[field],list):
        SourceList = source
        for iSource,source in enumerate(SourceList):
            target = os.path.join(sharedir,os.path.basename(source))
            shutil.copyfile(source, target)
            if FLAG_LOCALDATA:
                stub[field][iSource] = os.path.basename(target)
            else:
                stub[field][iSource] = os.path.join('..',target)
    else:
        target = os.path.join(sharedir,os.path.basename(source))
        shutil.copyfile(source, target)
        stub[field][iSource] = os.path.join('..',target)
        if FLAG_LOCALDATA:
            stub[field] = os.path.basename(target)
        else:
            stub[field] = os.path.join('..',target)

###############################################################
# Log files that all jobs will pull from SQUID in URLS_SHARED #
###############################################################
# After logging, the file path will be updated so that the
# executable will look for the file in the job's current
# directory. HTCondor transfers all files into the job directory
# and does not transfer directories, themselves.
URLS_shared = [field for field in stub['URLS'] if field not in EXPAND]
for field in URLS_shared:
    URLS = os.path.join(sharedir,'URLS_SHARED')
    with open(URLS,'w') as f:
        if isinstance(stub[field],list):
            SourceList = stub[field]
            for source in SourceList:
                f.write(source+'\n')
                stub[field][iSource] = os.path.basename(target)
        else:
            source = stub[field]
            f.write(source+'\n')
            stub[field] = os.path.basename(target)

if StubAsMaster:
    master = stub
else:
    master = pycon.expand_stub(stub)
    print "Writing master.yaml..."
    with open('master.yaml', 'w') as f:
        yaml.dump_all(configs, f)


#############################################################
#              Setup individual jobs structure              #
#############################################################
njobs = len(master)
print "Composing {njobs:d} individual jobs...".format(njobs=njobs)
width = ndigits(njobs-1)
JobDirs = [os.path.join(ROOTDIR, "{job:0{w}d}".format(job=i,w=width)) for i in xrange(N)]
COPY_uniq = [field for field in stub['COPY'] if field in EXPAND]
URLS_uniq = [field for field in stub['URLS'] if field in EXPAND]
for iJob,config in enumerate(master):
    p = (iJob+1)/njobs
    print "\r[{bar:20s}] {pct:.1f}".format(bar='#'*(p*20), pct=p*100),
    if not os.path.isdir(JobDirs[iJob]):
        os.makedirs(JobDirs[iJob])
    #############################################################
    #                       Copy files                          #
    #############################################################
    for field in COPY_uniq:
        if isinstance(config[field], list):
            SourceList = config[field]
            for iSource,source in enumerate(SourceList):
                target = os.path.join(JobDirs[iJob],os.path.basename(source))
                shutil.copyfile(source, target)
                config[field][iSource] = os.path.basename(target)
        else:
            target = os.path.join(JobDirs[iJob],os.path.basename(source))
            shutil.copyfile(source, target)
            config[field] = os.path.basename(target)

    #############################################################
    #                    Write URLS files                       #
    #############################################################
    URLS = os.path.join(JobDirs[iJob],'URLS')
    with open(URLS,'w') as f:
        for field in URLS_uniq:
            if isinstance(config[field], list):
                SourceList = config[field]
                for source in SourceList:
                    source_stripped = utils.lstrip_pattern(source,'/squid')
                    f.write(source_stripped +'\n')
                    config[field][iSource] = os.path.basename(target)
            else:
                source = config[field]
                source_stripped = utils.lstrip_pattern(source,'/squid')
                f.write(source_stripped +'\n')
                config[field][iSource] = os.path.basename(target)

    #############################################################
    #           Distribute params.json file to each job         #
    #############################################################
    paramfile = os.path.join(JobDirs[iJob],'params.json')
    del config['COPY']
    del config['URLS']
    with open(paramfile, 'w') as f:
        json.dump(config, f, sort_keys = True, indent = 4)

#############################################################
#          Perform other optional setup operations          #
#############################################################
# These require perl and probably additional system configuration.
if FLAG_SETUPDAG:
    FillDAGTemplate = [
            os.path.join(PERLBIN,'FillDAGTemplate.pl'),
            os.path.join(PERLTEMPLATES,'subdag.template'),
            str(len(master))]
    subprocess.call(FillDAGTemplate)

if FLAG_SETUPSUBMIT:
    FillProcessTemplate = [
            os.path.join(PERLBIN,'FillProcessTemplate.pl'),
            os.path.join(PERLTEMPLATES,'process.template'),
            str(len(master)),
            os.path.join('process.yaml')]
    subprocess.call(FillProcessTemplate)
