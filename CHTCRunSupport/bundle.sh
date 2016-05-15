#!/bin/bash
usage="$(basename "$0") [-hbc] [source] [...] [target] -- program to merge multiple
          directory trees into a new tree. The specific intended
          application is the merge *_in and *_out directory trees
          containing setup and result information for CHTC Condor.

where:
    -h     show this help text
    -b     Treat current sources to be bundled as if they constitute
           of many possible batches. This means that instead of
           merging the source directories into target, they are
           merged into a numbered directory within target.
    -c     Clean up the bundled directory by archiving log and dag
           files and removing the originals.
    -d     Run rsync in ``dry-run'' mode.
    source One or more source directories, at the root of the intended
           trees.
    target The location of the merged tree to construct.
"

CLEAN=0
BATCH=0
DRYRUN=0
while getopts ':hbcd' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    b) BATCH=1
       ;;
    c) CLEAN=1
       ;;
    d) DRYRUN=1
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

target=${!#}
target=${target%/}
if [[ $BATCH -eq 1 ]]
then
  BatchAffix="batch-"
  ProjectRoot=${target}
  if [[ -d "${target}" ]]
  then
    N=(`find ./${target} -type d -regex "./${target}/${BatchAffix}[0-9]+" | wc -l`)
    BatchDir=(`printf "${BatchAffix}%03d" $N`)
    target="${target}/${BatchDir}"
  else
    N=0
    BatchDir=(`printf "${BatchAffix}%03d" $N`)
    target="${target}/${BatchDir}"
    mkdir -p $target
  fi
  # Generate BATCHES.json
  BatchList=""
  for ((i=0;i<=$N;++i))
  do
    BatchList+=`printf "\"${BatchAffix}%03d/MASTER.json\"" $i`
    if [[ i -lt $N ]]
    then
      BatchList+=","
    fi
  done
  echo -e "{\"batches\": [${BatchList}]}" > ${ProjectRoot}/BATCHES.json
fi

args=("$@")
unset args[${#args[@]}-1]

echo "srcs: ${args[@]}"
echo "target: ${target}"
echo "clean?: ${CLEAN}"

for src in "${args[@]}"
do
  if [[ $DRYRUN -eq 1 ]]
  then
    rsync -auv --dry-run ${src} ${target}
  else
    rsync -au ${src} ${target}
  fi
done

if [[ $CLEAN -eq 1 ]]
then
  home=(`pwd`)
  cd $target
  # Package dag files
  find ./ -maxdepth 1 -type f \
    -name "*dag*" -print0 |   \
    xargs -0 tar -cz --remove-files -f dag_files.tgz
  # Package log files
  find ./ -mindepth 2 -maxdepth 2 -type f \
    -name "???_dag" \
    -o -name "*.out" \
    -o -name "ALL_DONE" \
    -o -name "*.log" \
    -o -name "*.cmd" \
    -o -name "*.err" \
    -o -name "CURLTIME_*" \
    -o -name "RESULT" \
    -o -name "ENVVARS" \
    -o -name "AuditLog.???" | \
    xargs -s 10000 tar -cz --remove-files -f log_files.tgz
  cd $home
fi
