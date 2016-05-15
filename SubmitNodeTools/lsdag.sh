#!/bin/bash
set -e

TMPDIR=$(mktemp -dt "$(basename $0).XXXXXXXXXX")
# Status Key
#   IDLE   = 1
#   ACTIVE = 2
#   HOLD   = 5

condor_q \
	-submitter $USER \
	-format "%d" DAGManJobID \
	-format ",%d" ClusterID \
	-format ".%d" ProcID \
	-format ",%d\n" JobStatus > $TMPDIR/condor_q.out

# Lines that correspond to running DAGs will not have a DAGManJobID, and so the
# first entry will be blank.
ACTIVEDAGS=$(awk 'BEGIN{FS=","}$1==""{print $2}' $TMPDIR/condor_q.out | tee ${TMPDIR}/active.id)
sed -i.bak 's/\.0//' ${TMPDIR}/active.id

if [ -f "${HOME}/.activedags" ]; then
  # Rewrite the activedag file and drop finished ones
  grep -f $TMPDIR/active.id ${HOME}/.activedags > $TMPDIR/active
  # Make a note of dag ids that are no longer in the queue. The || true is because
  # the file might be empty, and this usually raises exit status 1
  grep -v -f $TMPDIR/active.id ${HOME}/.activedags > $TMPDIR/finished || true
fi

echo "Active DAGs:"
printf "%8s%16s%8s%8s%8s%8s%8s%8s\n" "ID" "Label" "Idle" "Active" "Hold" "NJobs" "Done" "Pct"
for dag in $ACTIVEDAGS; do
  dagc=${dag%.0}
  nidle=$(awk -v dagc=$dagc 'BEGIN{FS=",";N=0} ($1==dagc) && ($3==1) {N++} END{print N}' $TMPDIR/condor_q.out)
  nactive=$(awk -v dagc=$dagc 'BEGIN{FS=",";N=0} ($1==dagc) && ($3==2) {N++} END{print N}' $TMPDIR/condor_q.out)
  nhold=$(awk -v dagc=$dagc 'BEGIN{FS=",";N=0} ($1==dagc) && ($3==5) {N++} END{print N}' $TMPDIR/condor_q.out)
  if [ -f "${TMPDIR}/active" ]; then
    dagdir=$(awk -v dagc=$dagc 'BEGIN{FS=","} ($1==dagc) {print $2}' ${TMPDIR}/active)
    label=$(awk -v dagc=$dagc 'BEGIN{FS=","} ($1==dagc) {print $3}' ${TMPDIR}/active)
    njobs=$(awk -v dagc=$dagc 'BEGIN{FS=","} ($1==dagc) {print $4}' ${TMPDIR}/active)
    ndone=$(find "$dagdir" -maxdepth 2 -type f -name "results.mat"|wc -l)
    pdone=$(awk -v dividend="${ndone}" -v divisor="${njobs}" 'BEGIN {printf "%.2f", (dividend/divisor)*100; exit(0)}')
    sed -i.bak "s:^${dagc}.*:${dagc},${dagdir},${label},${njobs},${ndone},${nidle},${nactive},${nhold}:" $TMPDIR/active
  fi
  printf "%8d%16s%8d%8d%8d%8d%8d%8.2f%%\n" "$dagc" "$label" "$nidle" "$nactive" "$nhold" "$njobs" "$ndone" "${pdone}"
done
if [ -f $TMPDIR/finished ]; then
  echo ""
  echo "Finished DAGs"
  printf "%8s%16s\n" "ID" "Label"
  awk 'BEGIN{FS=","}{printf "%8d%16s\n" $1, $3}' $TMPDIR/finished
fi

mv $TMPDIR/active ${HOME}/.activedags
rm -rf $TMPDIR
