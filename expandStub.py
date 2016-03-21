#!/usr/bin/env python

import yaml
import sys
import os
import shutil
from operator import mul

assert len(sys.argv) == 2

stubfile = sys.argv[1]
home = os.path.dirname(stubfile)
masterfile = os.path.join(home, 'master.yaml')
ExpandFields = []

with open(stubfile, 'r') as f:
    ydat = yaml.load(f)

print ydat

try:
    ToExpand = ydat['ExpandFields']
    del ydat['ExpandFields']
except KeyError:
    shutil.copyfile(stubfile, masterfile)
    sys.exit(0)

nPerField = []
for field in ToExpand:
	if isinstance(field,list) or isinstance(field,tuple):
		flength = []
		for k in field:
			flength.append(len(ydat[k]))

		if not all([fl==flength[0] for fl in flength]):
			print "condortools:ExpandStub:error: Linked fields are of different lengths."
			sys.exit(1)

		nPerField.append(flength[0])
	else:
		k = field
		nPerField.append(len(ydat[k]))

N = reduce(mul, nPerField, 1)

if N > 1000:
    print "WARNING! About to expand the stub into {n:d} configs. Is this what you want?".format(n=N)
    decision = raw_input('[y/n]: ').lower()
    if not decision == "y":
        print "Exiting..."
        sys.exit(0)

configs = [dict(ydat) for i in xrange(N)]
for i in xrange(N):
    inds = ind2sub(nPerField, i)
    for ii,field in enumerate(ToExpand):
		if isinstance(field,list) or isinstance(field,tuple):
			for k in field:
				configs[i][k] = ydat[k][inds[ii]]
		else:
			k = field
			configs[i][k] = ydat[k][inds[ii]]

with open(masterfile, 'w') as f:
    yaml.dump_all(configs, f)
