#!/usr/bin/env python

import csv
import json
import os
import sys
from datetime import datetime
import tarfile
import shutil
import pycon

try:
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('master')
    p.add_argument('-r','--run',action='store_true',
        help="In addition to setting up the directory structure, run all analyses. Useful when the analysis is being done locally.")
    p.add_argument('-c','--copy_data_src',action='store_true',
        help="This flag indicates that data and source files should be copied into the shared directory.")
    args = p.parse_args()
except ImportError:
    # Specify type of input associated with argument:
    #   If you specify an integer, that declares the expected
    #   number of inputs.
    #   If you define an empty list, the number of inputs is taken
    #   to be > 0 but bounded.
    #   If you specify a logical value, this means that the flag
    #   takes no inputs, and it's presence will flip this default
    #   value.
    pargnames = ['master']
    argtype = {'run':False}

    # Specify translation from valid flags to valid arguments.
    flags = {'-r':'run','--r':'run'}

    # Parse the arguments
    arglst = sys.argv[1:]
    args = pycon.argparse(arglst, pargnames, argtype, flags)

#############################################################
#   Load data and parameters from the "master" json file    #
#############################################################
jsonfile = args.master
with open(jsonfile,'rb') as f:
    jdat = json.load(f)

#############################################################
#     Set a current config that inherits defaults to be     #
#        potentially overwritten by individual configs      #
#############################################################
try:
    allConfigs = jdat['config']
except KeyError:
    # This just ensures there is a list to loop over.
    # The idea is to initialize currentConfig with defaults and then update
    # those with the paramaters from each config dict.
    allConfigs = [jdat]

#############################################################
#  Define a root folder (current directory if not a condor  #
#                           run)                            #
#############################################################
rootdir = ''
try:
    if jdat['condor']:
        rootdir = jdat['version']
except KeyError:
    pass

#############################################################
#                 Setup directory structure                 #
#############################################################
sharedir = os.path.join(rootdir,'shared')
if not os.path.isdir(sharedir):
    os.makedirs(sharedir)

archivedir = os.path.join(rootdir,'archive')
if not os.path.isdir(archivedir):
    os.makedirs(archivedir)

#############################################################
#      Copy shared source and binary files into place       #
#############################################################
if args.copy_data_src:
    try:
        shutil.copy(jdat['binary'],sharedir)
    except KeyError:
        print "No shared binary indicated."

    try:
        if isinstance(jdat['srcdir'], list):
            srclst = jdat['srcdir']
        else:
            srclst = [jdat['srcdir']]

        for srcdir in srclst:
            src_files = os.listdir(srcdir)
            for file_name in src_files:
                full_file_name = os.path.join(srcdir, file_name)
                if (os.path.isfile(full_file_name)):
                    shutil.copy(full_file_name, sharedir)
    except KeyError:
        print "No shared source directory indicated."

#############################################################
#       Copy shared data / Write shared URLS file           #
#############################################################
URLS = os.path.join(sharedir,'URLS_SHARED')
try:
    if isinstance(jdat['data'],list):
        datalst = jdat['data']
        jdat['data'] = [os.path.split(x)[1] for x in jdat['data']]
    else:
        datalst = [jdat['data']]
        jdat['data'] = os.path.split(jdat['data'])[1]

    with open(URLS,'w') as f:
        for x in datalst:
            pathparts = x.split(os.sep)
            if x[:6] == '/squid':
                p = os.path.join('/',*pathparts[2:])
                f.write(p+'\n')
            else:
                if args.copy_data_src:
                    shutil.copy(x,sharedir)
except KeyError:
    print "No shared data files indicated."

try:
    if isinstance(jdat['metadata'],list):
        datalst = jdat['metadata']
        jdat['metadata'] = [os.path.split(x)[1] for x in jdat['metadata']]
    else:
        datalst = [jdat['metadata']]
        jdat['metadata'] = os.path.split(jdat['metadata'])[1]

    with open(URLS,'a') as f:
        for x in datalst:
            pathparts = x.split(os.sep)
            if x[:6] == '/squid':
                p = os.path.join('/',*pathparts[2:])
                f.write(p+'\n')
            else:
                if args.copy_data_src:
                    shutil.copy(x,sharedir)
except KeyError:
    print "No shared metadata indicated."

#############################################################
#        Loop over configs (if condor, do setup only)       #
#############################################################
for i, cfg in enumerate(allConfigs):
    # Reset to defaults on each loop
    currentConfig = jdat.copy()
    try:
        # Strip out the config list if it exists
        del currentConfig['config']
    except KeyError:
        pass

    # Update defaults with the new config data
    currentConfig.update(cfg)

    jobdir = os.path.join(rootdir,'{cfgnum:03d}'.format(cfgnum=i))
    os.makedirs(jobdir)

    cfgfile = os.path.join(jobdir,'params.json')

    #############################################################
    #       Copy job source and binary files into place         #
    #############################################################
    if args.copy_data_src:
        try:
            shutil.copy(cfg['binary'],sharedir)
        except KeyError:
            pass

        try:
            if isinstance(jdat['srcdir'], list):
                srclst = jdat['srcdir']
            else:
                srclst = [jdat['srcdir']]

            for srcdir in srclst:
                src_files = os.listdir(srcdir)
                for file_name in src_files:
                    full_file_name = os.path.join(srcdir, file_name)
                    if (os.path.isfile(full_file_name)):
                        shutil.copy(full_file_name, sharedir)
        except KeyError:
            pass

    #############################################################
    #          Copy job data / Write shared URLS file           #
    #############################################################
    URLS = os.path.join(jobdir,'URLS')
    try:
        if isinstance(cfg['data'],list):
            datalst = cfg['data']
            currentConfig['data'] = [os.path.split(x)[1] for x in cfg['data']]
        else:
            datalst = [cfg['data']]
            currentConfig['data'] = os.path.split(cfg['data'])[1]

        with open(URLS,'w') as f:
            for x in datalst:
                pathparts = x.split(os.sep)
                if x[:6] == '/squid':
                    p = os.path.join('/',*pathparts[2:])
                    f.write(p+'\n')
                else:
                    if args.copy_data_src:
                        shutil.copy(x,sharedir)
    except KeyError:
        pass

    try:
        if isinstance(cfg['metadata'],list):
            datalst = cfg['metadata']
            currentConfig['metadata'] = [os.path.split(x)[1] for x in cfg['metadata']]
        else:
            datalst = [cfg['metadata']]
            currentConfig['metadata'] = os.path.split(cfg['metadata'])[1]

        with open(URLS,'a') as f:
            for x in datalst:
                pathparts = x.split(os.sep)
                if x[:6] == '/squid':
                    p = os.path.join('/',*pathparts[2:])
                    f.write(p+'\n')
                else:
                    shutil.copy(x,sharedir)
    except KeyError:
        pass

    with open(cfgfile,'wb') as f:
        json.dump(currentConfig, f, sort_keys=True, indent=2, separators=(',', ': '))
