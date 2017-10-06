require 'rake'
require 'yaml'
require 'tempfile'
require 'fileutils'
# CRC: This was having a hard time using 7zip
# require 'rake/packagetask'
# CRC: In my current development environment (Windows 7, Ruby 2.3.3p222
# (2016-11-21 revision 56859) [x64-mingw32], Rake 10.4.2), the 'clean' and
# 'clobber' tasks hung forever. I may have been setting things up wrong, but it
# is not a complicated thing to mess up... ultimately, I wrote my own clean
# task, which is not ideal.
# require 'rake/clean'

# CRC: Despite adding PYSCRIPTDIR to my Windows environment, sh() was unable to
# locate quickstub. So I have specified it here, and all references to my
# Python scripts will utilize the full absolute path.
# PYSCRIPTDIR='C:/Users/mbmhscc4/AppData/Roaming/Python/Python36/Scripts'
PYSCRIPTDIR='C:\Users\coxcr\Documents\GitHub\condortools'
QUICKSTUB=File.join(PYSCRIPTDIR,'quickstub')
# CRC: It was a giant hassle to sh() to propperly call 7zip. I ended up copying
# the executable into the working directory. There *must* be some other way to
# get it to work, but it seemed to be choking on the space in "Program Files",
# no matter how I quoted it.
ZIP="./7z.exe a -spf"

# CRC: SQUIDDIR, DATAFILE, and METAFILE are not being used. Instead, these
# bits of information are being read from the stub files associated with the
# hyperparameter tuning for each analysis.
#
SQUIDDIR="/squid/crcox/MRI/Manchester/MAT/avg/bystudy"
DATAFILE = Rake::FileList[
  's01_avg.mat',
  's02_avg.mat',
  's03_avg.mat',
  's04_avg.mat',
  's05_avg.mat',
  's06_avg.mat',
  's07_avg.mat',
  's08_avg.mat',
  's09_avg.mat',
  's10_avg.mat',
  's11_avg.mat',
  's12_avg.mat',
  's13_avg.mat',
  's14_avg.mat',
  's15_avg.mat',
  's16_avg.mat',
  's17_avg.mat',
  's18_avg.mat',
  's19_avg.mat',
  's20_avg.mat',
  's21_avg.mat',
  's22_avg.mat',
  's23_avg.mat'
].pathmap("#{SQUIDDIR}/%f")
METAFILE = File.join(SQUIDDIR,"metadata_avg_wAnimate.mat")

RESULTDIR = Rake::FileList[
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AS/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/ASV/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AV/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/SV/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/A/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/AS/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/ASV/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/AV/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/S/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/SV/bystudy/L1L2/performance/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/V/bystudy/L1L2/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/A/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/AS/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/ASV/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/AV/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/S/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/SV/performance/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/V/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/A/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/AS/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/ASV/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/AV/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/S/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/SV/performance/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/V/performance/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AS/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/ASV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/SV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/A/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AS/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/ASV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/S/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/SV/performace/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/V/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/A/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/AS/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/ASV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/AV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/S/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/SV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/V/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/A/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/AS/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/ASV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/AV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/S/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/SV/performace/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/V/performace/tune',
    'wholebrain/semantic/avg/audio/L1L2/bystudy/performance/tune',
    'wholebrain/semantic/avg/visual/L1L2/bystudy/performance/tune',
    'wholebrain/visual/chamfer/chamfer/audio/L1L2/bystudy/performance/tune',
    'wholebrain/visual/chamfer/chamfer/visual/L1L2/bystudy/performance/tune'
]
RESULTDIR_VISUALIZATION = Rake::FileList[
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AS/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/ASV/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AV/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/SV/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/A/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/AS/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/ASV/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/AV/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/S/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/SV/bystudy/L1L2/visualization/tune',
    'lesion/semantic/similarity/featurenorms/cosine/visual/avg/V/bystudy/L1L2/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/A/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/AS/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/ASV/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/AV/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/S/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/SV/visualization/tune',
    'lesion/visual/chamfer/chamfer/audio/L1L2/bystudy/V/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/A/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/AS/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/ASV/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/AV/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/S/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/SV/visualization/tune',
    'lesion/visual/chamfer/chamfer/visual/L1L2/bystudy/V/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AS/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/ASV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/SV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/A/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AS/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/ASV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/S/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/SV/visualization/tune',
    'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/V/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/A/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/AS/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/ASV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/AV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/S/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/SV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/audio/avg/bystudy/V/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/A/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/AS/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/ASV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/AV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/S/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/SV/visualization/tune',
    'roi/visual/similarity/chamfer/chamfer/visual/avg/bystudy/V/visualization/tune',
    'wholebrain/semantic/avg/audio/L1L2/bystudy/visualization/tune',
    'wholebrain/semantic/avg/visual/L1L2/bystudy/visualization/tune',
    'wholebrain/visual/chamfer/chamfer/audio/L1L2/bystudy/visualization/tune',
    'wholebrain/visual/chamfer/chamfer/visual/L1L2/bystudy/visualization/tune'
]
HYPERPARAMETERS = {
  :bias => 1,
  :normalize => 'zscore',
  :lambda => {
    :distribution => 'uniform',
    :args => [1,16]},
  :HYPERBAND => {
    :budget => 100,
    :aggressiveness => 3,
    :hyperparameters => ['lambda']},
  :cvscheme => 1,
  :cvholdout => [1,2,3,4,5,6,7,8,9],
  :finalholdout => 0,
  :metadata_var => 'metadata',
  :orientation => 'orig',
  :target_type => 'similarity',
  :SmallFootprint => 1,
  :executable => '/home/crcox/src/WholeBrain_RSA/bin/R2014b/WholeBrain_RSA',
  :wrapper => '/home/crcox/src/WholeBrain_RSA/run_WholeBrain_RSA.sh',
  :EXPAND => ['data','cvholdout'],
  :COPY => ['executable', 'wrapper'],
  :URLS => ['data', 'metadata']
}
CONDITIONS = [
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_audio','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_semantic','LESION_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','LESION_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_audio','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_audio','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_semantic','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_audio','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud',['ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','ROI_visual','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_audio','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_audio','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_semantic','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud',['ROI_semantic','ROI_visual'],'NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_aud','colfilter_aud','ROI_visual','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','NOT_rain']},
  {:tau => 0.3, :target => 'semantic', :sim_source => 'featurenorms', :sim_metric => 'cosine',  :data_var => 'visual', :filters => ['rowfilter_vis','colfilter_vis','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'audio',  :filters => ['rowfilter_aud','colfilter_aud','NOT_rain']},
  {:tau => 0.2, :target => 'visual',   :sim_source => 'chamfer',      :sim_metric => 'chamfer', :data_var => 'visual', :filters => ['rowfilter_vis','colfilter_vis','NOT_rain']}
]
TUNECSV = RESULTDIR.collect{|c| Rake::FileList["#{c}/HB_?.csv"]}
FINALDIR = RESULTDIR.pathmap("%d/final")
PERMDIR = RESULTDIR.pathmap("%d/permutations")
FINALYAML = FINALDIR.pathmap("%p/stub.yaml")
PERMYAML = PERMDIR.pathmap("%p/stub.yaml")
TUNEYAML_VISUALIZATION = RESULTDIR_VISUALIZATION.pathmap("%p/HB_0/stub.yaml")

FINALDIR.zip(PERMDIR).each do |d,p|
  directory d
  directory p
end

cmd = "python #{QUICKSTUB}"
TUNEYAML_VISUALIZATION.zip(CONDITIONS,RESULTDIR_VISUALIZATION).each do |stub,condition|
  file stub do
    d = File.dirname(stub)
    FileUtils.mkdir_p(d)
    tmpyaml = Tempfile.new(['config','.yaml'])
    begin
      tmpyaml.write(condition.merge(HYPERPARAMETERS).to_yaml)
      sh("#{cmd} -c #{tmpyaml.path} -o #{stub} -- nrsa")
    ensure
      tmpyaml.close
      tmpyaml.unlink
    end
  end
end

cmd = "python #{QUICKSTUB}"
FINALYAML.zip(TUNECSV,RESULTDIR).each do |final,tune,td|
  file final => tune do
    sh("#{cmd} -s #{td}/HB_0/stub.yaml -t #{tune.join(' ')} -b subject finalholdout -p lambda -x err1 -o #{final} -- nrsa")
  end
end

PERMYAML.zip(TUNECSV,RESULTDIR).each do |perm,tune,td|
  file perm => tune do
    sh("#{cmd} -s #{td}/HB_0/stub.yaml -t #{tune.join(' ')} -r 100 10 -b subject finalholdout -p lambda -x err1 -o #{perm} -- nrsa")
  end
end

task :dirs => FINALDIR
task :stub => FINALDIR + FINALYAML + PERMDIR + PERMYAML
task :zip => FINALYAML do
  sh("#{ZIP} stubs.zip #{FINALYAML} #{PERMYAML}")
end
task :clean do
  FINALYAML.zip(PERMYAML).each do |f,p|
    rm_f f
    rm_f p
  end
end

namespace :final do
  task :stub => FINALDIR + FINALYAML
  task :zip => FINALYAML do
    sh("#{ZIP} stubs_final.zip #{FINALYAML}")
  end
  task :clean do
    FINALYAML.each do |f|
      rm_f f
    end
  end
end
namespace :perm do
  task :stub => PERMDIR + PERMYAML
  task :zip => PERMYAML do
    sh("#{ZIP} stubs_perm.zip #{PERMYAML}")
  end
  task :clean do
    PERMYAML.each do |p|
      rm_f p
    end
  end
end
namespace :tune do
  namespace :performance do
    task :stub
  end
  namespace :visualization do
    task :stub => TUNEYAML_VISUALIZATION
  end
  task :zip => TUNECSV.flatten do
    sh("#{ZIP} tune_HB.zip #{TUNECSV.flatten}")
  end
end

#  'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/visual/avg/A/bystudy/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/visual/avg/AS/bystudy/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/visual/avg/S/bystudy/L1L2/performance/tune',
#  'lesion/semantic/similarity/featurenorms/cosine/visual/avg/V/bystudy/L1L2/performance/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/A/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AS/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/ASV/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/AV/performace/tune',
#  #'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/S/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/SV/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/audio/avg/bystudy/V/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/A/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AS/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/ASV/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/AV/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/S/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/SV/performace/tune',
#  'roi/semantic/similarity/featurenorms/cosine/visual/avg/bystudy/V/performace/tune',
#  'wholebrain/semantic/avg/audio/L1L2/bystudy/performance/tune',
#  'wholebrain/semantic/avg/visual/L1L2/bystudy/performance/tune',
#  'wholebrain/visual/chamfer/chamfer/audio/L1L2/bystudy/performance/tune',
#  'wholebrain/visual/chamfer/chamfer/visual/L1L2/bystudy/performance/tune'
