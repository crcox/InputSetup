<%page args="ProcessInfo,UNIQUE,JOBDIR"/>
<%
  if 'OSGConnect' in ProcessInfo and ProcessInfo['OSGConnect']:
    isOSG=ProcessInfo['OSGConnect']
  else:
    isOSG=False

  if 'ProxyURL' in ProcessInfo and ProcessInfo['ProxyURL']:
    ProxyURL=ProcessInfo['ProxyURL']
  else:
    ProxyURL=False

  if 'ProjectName' in ProcessInfo and ProcessInfo['ProjectName']:
    PROJECT=ProcessInfo['ProjectName']
  else:
    PROJECT=False

  if 'AccountingGroup' in ProcessInfo and ProcessInfo['AccountingGroup']:
    AccountingGroup=ProcessInfo['AccountingGroup']
  else:
    AccountingGroup=False

  if 'FLOCK' in ProcessInfo and ProcessInfo['FLOCK']:
    FLOCK=ProcessInfo['FLOCK']
  else:
    FLOCK=False

  if 'GLIDE' in ProcessInfo and ProcessInfo['GLIDE']:
    GLIDE=ProcessInfo['GLIDE']
  else:
    GLIDE=False

  if 'SHAREDIR' in ProcessInfo and ProcessInfo['SHAREDIR']:
    SHAREDIR=ProcessInfo['SHAREDIR']
  else:
    SHAREDIR='../shared'

  if 'WRAPPER' in ProcessInfo and ProcessInfo['WRAPPER']:
    WRAPPER=ProcessInfo['WRAPPER']
  else:
    WRAPPER=''

  if 'EXECUTABLE' in ProcessInfo and ProcessInfo['EXECUTABLE']:
    EXECUTABLE=ProcessInfo['EXECUTABLE']
  else:
    EXECUTABLE=''

  if 'PRESCRIPT' in ProcessInfo and ProcessInfo['PRESCRIPT']:
    PRESCRIPT=ProcessInfo['PRESCRIPT']
  else:
    PRESCRIPT=''

  if 'POSTSCRIPT' in ProcessInfo and ProcessInfo['POSTSCRIPT']:
    POSTSCRIPT=ProcessInfo['POSTSCRIPT']
  else:
    POSTSCRIPT=''

  if 'request_memory' in ProcessInfo and ProcessInfo['request_memory']:
    request_memory=ProcessInfo['request_memory']
  else:
    request_memory='0KB'

  if 'request_disk' in ProcessInfo and ProcessInfo['request_disk']:
    request_disk=ProcessInfo['request_disk']
  else:
    request_disk='0KB'

  if 'execPArgs' in ProcessInfo and ProcessInfo['execPArgs']:
    execPArgs=ProcessInfo['execPArgs']
  else:
    execPArgs=[]

  if 'execKVArgs' in ProcessInfo and ProcessInfo['execKVArgs']:
    execKVArgs=ProcessInfo['execKVArgs']
  else:
    execKVArgs=[]
%>
# MAKE SURE TO CHANGE THE FIRST SECTION BELOW FOR EACH NEW SUBMISSION!!!
% if 'ProjectName' in ProcessInfo and not ProcessInfo['ProjectName'] is None:
+ProjectName = ${PROJECT}
#
% endif
% if 'AccountingGroup' in ProcessInfo and not ProcessInfo['AccountingGroup'] is None:
+AccountingGroup = ${AccountingGroup}
#
% endif

% if 'FLOCK' in ProcessInfo and not ProcessInfo['FLOCK'] is None:
# By default, your job will be submitted to the CHTC's HTCondor
# Pool only, which is good for jobs that are each less than 24 hours.
#
# If your jobs are less than 4 hours long, "flock" them additionally to
# other HTCondor pools on campus.
+WantFlocking = ${FLOCK}
#
% endif
% if 'GLIDE' in ProcessInfo and not ProcessInfo['GLIDE'] is None:
# If your jobs are less than ~2 hours long, "glide" them to the national
# Open Science Grid (OSG) for access to even more computers and the
# fastest overall throughput.
+WantGlidein = ${GLIDE}
#
% endif
# Tell Condor how many CPUs (cores), how much memory (MB) and how much
# disk space (KB) each job will need:
request_cpus = 1

request_memory = ${size_conversion(request_memory,'MB')}
request_disk = ${size_conversion(request_disk,'KB')}

# SECOND SECTION: Unlikely that you'll need to change this each time
# The below lines indicate that all files necessary for each job
# need to be transfered to it. Only modify these if you have implemented
# self-checkpointing; change "when_to_transfer_output" to "ON_EXIT_OR_EVICT".
should_transfer_files = YES
when_to_transfer_output = ON_EXIT_OR_EVICT

# If you want your jobs to go on hold because they are
# running longer then expected,  uncomment this line and
# change from 24 hours to desired limit:
<%text>#periodic_hold = (JobStatus == 2) && ((CurrentTime - EnteredCurrentStatus) > (60 * 60 * 24))</%text>

# YOU SHOULD NOT NEED TO CHANGE ANYTHING BELOW THIS LINE
#
# This is a "normal" job.
universe = vanilla

# This wrapper script automates setting R or Matlab up.
executable = ${WRAPPER}
% if isOSG:
<%text>requirements = OSGVO_OS_STRING == "RHEL 6" && Arch == "X86_64" && HAS_MODULES == True</%text>
% else:
<%text>requirements = (OpSysMajorVer =?= 6)</%text>
% endif


# If anything is output to standard output or standard error,
# where should it be saved?
output = process.out
error = process.err

# Where to write a log of your jobs statuses.
log = process.log

# Arguments to the wrapper script.  Of note is the last one, --, anything
# after this goes direct to your R, Matlab or Other code.
# This gets augmented for you by mkdag.pl. Choose R or Matlab
arguments = "${EXECUTABLE} ${UNIQUE} ${ProxyURL} ${isOSG} -- ${join_with_spaces(execPArgs)|trim} ${join_with_spaces(execKVArgs)|trim}"

# Release a job from being on hold hold after half an hour (1800 seconds), up to 4 times,
# as long as the executable could be started, the input files and initial directory
# were accessible and the user log could be created. This will help your jobs to retry
# if they happen to fail due to a computer issue (not an issue with your job)
<%text>periodic_release = (JobStatus == 5) && ((CurrentTime - EnteredCurrentStatus) > 1800) && (JobRunCount < 5) && (HoldReasonCode != 6) && (HoldReasonCode != 14) && (HoldReasonCode != 22)</%text>
#

# We dont want email about our jobs. (If you do, let us know,
# there may be some additional configuration necessary.)
notification = never

# This line is completed for you
transfer_input_files = ./, ${SHAREDIR}/

queue

<%def name="join_with_spaces(args)" filter="trim">
  <%
    line = []
    try:
      for k,v in args.items():
        line.extend([k,v])

    except AttributeError:
      for v in args:
        line.append(v)

    output = ' '.join(str(x) for x in line)
  %>
${output}
</%def>
<%def name="size_conversion(x, convert_to)" filter="trim">
  <%
    UNITSIZE={'KB':10e3,'MB':10e6,'GB':10e9}
    n=int(x[:-2])
    unit=x[-2:]
    bytes_ = n*UNITSIZE[unit]
    output = int(bytes_/UNITSIZE[convert_to.upper()])
  %>
${output}
</%def>
<%def name="yesno(x)" filter="trim">
% if x:
YES
% else:
NO
% endif
</%def>
