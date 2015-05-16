#!/usr/bin/env python

import yaml
import json
import sys
import os
import shutil
from operator import mul
#from numpy import unravel_index

def ind2sub( sizes, index ):
    """
    Map a scalar index of a flat 1D array to the equivalent
    d-dimensional index
    Example:
    | 1  4  7 |      | 1,1  1,2  1,3 |
    | 2  5  8 |  --> | 2,1  2,2  2,3 |
    | 3  6  9 |      | 3,1  3,2  3,3 |
    """
    denom = reduce(mul, sizes, 1)
    num_dims = len(sizes)
    multi_index = [0 for i in range(num_dims)]
    for i in xrange( num_dims - 1, -1, -1 ):
        denom /= sizes[i]
        multi_index[i] = index / denom
        index = index % denom
    return multi_index

assert len(sys.argv) == 2

stubfile = sys.argv[1]
home = os.path.dirname(stubfile)
masterfile = os.path.join(home, 'master.yaml')

with open(stubfile, 'r') as f:
    ydat = yaml.load(f)

print ydat

try:
    ToExpand = ydat['ExpandFields']
    del ydat['ExpandFields']
except KeyError:
    shutil.copyfile(stubfile, masterfile)
    sys.exit(0)

n = [len(ydat[x]) for x in ToExpand]
N = reduce(mul, n, 1)

if N > 1000:
    print "WARNING! About to expand the stub into {n:d} configs. Is this what you want?".format(n=N)
    decision = raw_input('[y/n]: ').lower()
    if not decision == "y":
        print "Exiting..."
        sys.exit(1)

configs = [dict(ydat) for i in xrange(N)]

print N
print n
for i in xrange(N):
    #inds = unravel_index(i, n)
    inds = ind2sub(n, i)
    for ii,k in enumerate(ToExpand):
        configs[i][k] = ydat[k][inds[ii]]

with open(masterfile, 'w') as f:
    yaml.dump_all(configs, f)
