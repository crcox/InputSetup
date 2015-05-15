#!/usr/bin/env  python

import os
import json
import sys
import itertools
import argparse

p = argparse.ArgumentParser()
p.add_argument('stub')
p.add_argument('-k','--keys',nargs='+',
    help="List of keys that contain lists that need to be expanded across multiple configs.")
args = p.parse_args()

with open(args.stub, 'rb') as f:
    jdat = json.load(f)

x = []
for k in args.keys:
    x.append(list(jdat[k]))
    jdat.pop(k,0)

params = jdat.copy()

jdat['config'] = []
for i,config in enumerate(itertools.product(*x)):
    d = dict(zip(args.keys,config))
    jdat['config'].append(d)
    params.update(d)

with open('master.json','wb') as f:
    json.dump(jdat,f,sort_keys=True,indent=2,separators=(',',': '))
