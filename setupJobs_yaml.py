#!/usr/bin/env python
import subprocess
import yaml
import json
import os
import sys
import shutil
import argparse
import math
def ndigits(i):
    # Will return the number of digits in an integer.
    if i > 0:
        d = int(math.log10(i))+1
    elif i == 0:
        d = 1
    else:
        d = int(math.log10(-n))+1

    return d

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

width = ndigits(len(ydat)-1)
# Determine which fields are shared across all jobs
# Assumption is that all dictionaries in ydat have the same keys. This should
# be true for the output of expandStub_yaml.py
SharedFields = []
for key in ydat[0].keys():
    ref = ydat[0][key]
    same = [ref==ydat[i][key] for i in xrange(len(ydat))]
    if all(same):
        SharedFields.append(key)

#############################################################
#  Define a root folder (current directory if not a condor  #
#                           run)                            #
#############################################################
rootdir = '.'

#############################################################
#                 Setup directory structure                 #
#############################################################
sharedir = os.path.join(rootdir,'shared')
if not os.path.isdir(sharedir):
    os.makedirs(sharedir)

#############################################################
#                   Copy files into place                   #
#############################################################
if 'COPY' in ydat[0]:
    assert 'COPY' in SharedFields
    if isinstance(ydat[0]['COPY'],list):
        toCOPY = ydat[0]['COPY']
    else:
        toCOPY = [ydat[0]['COPY']]

    SharedCOPY = []
    for field in toCOPY:
        if field in SharedFields:
            shareddata = ydat[0][field]
            if isinstance(shareddata,list):
                SharedCOPY.extend(shareddata)
            else:
                SharedCOPY.append(shareddata)

        else:
            for i in xrange(len(ydat)):
                jobdir = os.path.join(rootdir, "{job:0{w}d}".format(job=i,w=width))
                if not os.path.isdir(jobdir):
                    os.makedirs(jobdir)
                data = ydat[i][field]
                if isinstance(data,list):
                    for d in data:
                        dataDest = os.path.join(jobdir,os.path.basename(d))
                        dsquid = os.path.join('/squid',d.lstrip('/'))
                        samefile = False
                        if os.path.isfile(dataDest):
                            try:
                                samefile = os.path.samefile(dsquid,dataDest)
                            except OSError:
                                samefile = os.path.samefile(d,dataDest)
                        if not samefile:
                            try:
                                shutil.copyfile(dsquid, dataDest)
                            except IOError:
                                shutil.copyfile(d, dataDest)
                else:
                    dataDest = os.path.join(jobdir,os.path.basename(data))
                    dsquid = os.path.join('/squid',d.lstrip('/'))
                    samefile = False
                    if os.path.isfile(dataDest):
                        try:
                            samefile = os.path.samefile(dsquid,dataDest)
                        except OSError:
                            samefile = os.path.samefile(data,dataDest)
                    if not samefile:
                        try:
                            shutil.copyfile(dsquid, dataDest)
                        except IOError:
                            shutil.copyfile(data, dataDest)

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

    if SharedCOPY:
        data = SharedCOPY
        if isinstance(data,list):
            for d in data:
                dataDest = os.path.join(sharedir,os.path.basename(d))
                dsquid = os.path.join('/squid',d.lstrip('/'))
                samefile = False
                if os.path.isfile(dataDest):
                    try:
                        samefile = os.path.samefile(dsquid,dataDest)
                    except OSError:
                        samefile = os.path.samefile(d,dataDest)
                if not samefile:
                    try:
                        shutil.copyfile(dsquid, dataDest)
                    except IOError:
                        shutil.copyfile(d, dataDest)
        else:
            dataDest = os.path.join(sharedir,os.path.basename(data))
            dsquid = os.path.join('/squid',data.lstrip('/'))
            samefile = False
            if os.path.isfile(dataDest):
                try:
                    samefile = os.path.samefile(dsquid,dataDest)
                except OSError:
                    samefile = os.path.samefile(data,dataDest)

            if not samefile:
                try:
                    shutil.copyfile(dsquid, dataDest)
                except IOError:
                    shutil.copyfile(data, dataDest)



#############################################################
#                    Write URLS files                       #
#############################################################
if 'URLS' in ydat[0]:
    assert 'URLS' in SharedFields
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
                jobdir = os.path.join(rootdir, "{job:0{w}d}".format(job=i,w=width))
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
            f.write('\n'.join(SharedURLS)+'\n')

#############################################################
#           Distribute params.json file to each job         #
#############################################################
for i, cfg in enumerate(ydat):
    jobdir = os.path.join(rootdir, "{job:0{w}d}".format(job=i,w=width))
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
