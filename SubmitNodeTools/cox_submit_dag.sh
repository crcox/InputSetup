#!/bin/bash
set -e

DAGFILE=$1
LABEL=$2
TMPDIR=$(mktemp -dt "$(basename $0).XXXXXXXXXX")

condor_submit_dag $DAGFILE | tee $TMPDIR/condor_submit_dag.out
if [ $? -ne 0 ]; then
  exit 1
fi

NJOBS=$(sed -n '/SPLICE/p' ${DAGFILE}|wc -l)
CLUSTID=$(sed -n 's/[0-9]\+ job(s) submitted to cluster \([0-9]\+\)./\1/p' $TMPDIR/condor_submit_dag.out)

echo "$CLUSTID,$(pwd),${LABEL},${NJOBS},0" >> ~/.activedags
