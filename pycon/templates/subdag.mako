<%page args="UNIQUE,JOBDIR,SUBMITFILE,PRESCRIPT='',POSTSCRIPT=''"/>
JOB ${UNIQUE} ${UNIQUE}/${SUBMITFILE} DIR ${JOBDIR}
% if PRESCRIPT:
SCRIPT PRE ${UNIQUE} ${PRESCRIPT}
% endif
% if POSTSCRIPT:
SCRIPT POST ${UNIQUE} ${POSTSCRIPT}
% endif
RETRY ${UNIQUE} 10
