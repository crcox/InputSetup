<%
  if ProcessInfo['FLOCK']:
    FLOCK=ProcessInfo['FLOCK']
  else:
    FLOCK=False

  if ProcessInfo['GLIDE']:
    GLIDE=ProcessInfo['GLIDE']
  else:
    GLIDE=False

  if ProcessInfo['SHAREDIR']:
    SHAREDIR=ProcessInfo['SHAREDIR']
  else:
    SHAREDIR='./shared'

  if ProcessInfo['WRAPPER']:
    WRAPPER=ProcessInfo['WRAPPER']
  else:
    WRAPPER=''

  if ProcessInfo['EXECUTABLE']:
    EXECUTABLE=ProcessInfo['EXECUTABLE']
  else:
    EXECUTABLE=''

  if ProcessInfo['PRESCRIPT']:
    PRESCRIPT=ProcessInfo['PRESCRIPT']
  else:
    PRESCRIPT=''

  if ProcessInfo['POSTSCRIPT']:
    POSTSCRIPT=ProcessInfo['POSTSCRIPT']
  else:
    POSTSCRIPT=''

  if ProcessInfo['request_memory']:
    request_memory=ProcessInfo['request_memory']
  else:
    request_memory='0KB'

  if ProcessInfo['request_disk']:
    request_disk=ProcessInfo['request_disk']
  else:
    request_disk='0KB'

  if ProcessInfo['execPArgs']:
    execPArgs=ProcessInfo['execPArgs']
  else:
    execPArgs=[]

  if ProcessInfo['execKVArgs']:
    execKVArgs=ProcessInfo['execKVArgs']
  else:
    execKVArgs=[]
%>
# MAKE SURE TO CHANGE THE FIRST SECTION BELOW FOR EACH NEW SUBMISSION!!!
#
# By default, your job will be submitted to the CHTC's HTCondor
# Pool only, which is good for jobs that are each less than 24 hours.
#
# If your jobs are less than 4 hours long, "flock" them additionally to
# other HTCondor pools on campus.
+WantFlocking = ${FLOCK}
#
# If your jobs are less than ~2 hours long, "glide" them to the national
# Open Science Grid (OSG) for access to even more computers and the
# fastest overall throughput.
+WantGlidein = ${GLIDE}
#
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
requirements = (OpSysMajorVer =?= 6)

# If anything is output to standard output or standard error,
# where should it be saved?
output = process.out
error = process.err

# Where to write a log of your jobs statuses.
log = process.log

# Tell us the versien of R or Matlab you are using. Place it
# in the JobAd. Choose one. Or comment both if it is some other
# kind of program.
<%text>#+${TYPE}="${VERSION}"</%text>
# Arguments to the wrapper script.  Of note is the last one, --, anything
# after this goes direct to your R, Matlab or Other code.
# This gets augmented for you by mkdag.pl. Choose R or Matlab
arguments = ${EXECUTABLE} ${UNIQUE} -- ${join_with_spaces(execPArgs)} ${join_with_spaces(execKVArgs)}

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
transfer_input_files = ${JOBDIR}/, ${SHAREDIR}/

# Leave the below line commented, unless you have a specific need for
# indicating a group that is not your default.
# See: http://monitor.chtc.wisc.edu/uw_condor_usage/usage1.shtml
#+AccountingGroup = "CHTC"


queue
<%def name="join_with_spaces(args)">
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
<%def name="size_conversion(x, convert_to)">
  <%
    UNITSIZE={'KB':10e3,'MB':10e6,'GB':10e9}
    n=int(x[:-2])
    unit=x[-2:]
    bytes_ = n*UNITSIZE[unit]
    output = n/UNITSIZE[convert_to.upper()]
  %>
${output}
</%def>
