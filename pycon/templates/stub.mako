% if method=="soslasso":
# SOS LASSO
# =========
regularization: soslasso

# Parameters
# ----------
% if verbose:
# bias toggles whether or not to use a bias unit when fitting models
# alpha scales the SOS Lasso penalty associated with picking items from
# different groups.
#
# lambda scales the overall sparsity penalty (irrespective of groups).
#
# shape defines the group shape. Can be sphere or cube.
#
# diameter defines the size of the group in millimeters. If you specify a
# single value, it applies to all three dimensions. Otherwise, you can provide
# a list of values, one for each dimension x, y, z.
#
# overlap defines that amount of overlap between groups in millimeters. If you
# specify a single value, it applies to all three dimensions. Otherwise, you
# can provide a list of values, one for each dimension x, y, z.
#
# normalize allows you to specify a normalization method to apply to your data
# before fitting models. zscore is recommended (subtract mean and divide by
# standard deviation), but stdev will simply divide by the standard deviation
# without recentering, and 2norm will subtract the mean and divide by the
# 2-norm (which is the euclidean distance between each voxel and the origin).
% endif
bias: 0
alpha: []
lambda: []
shape: sphere
diameter: 18
overlap: 9
normalize: zscore
% elif method=="lasso":
# LASSO
# =====
regularization: lasso_glmnet

# Parameters
# ----------
% if verbose:
# bias toggles whether or not to use a bias unit when fitting models
#
# lambda scales the overall sparsity penalty. N.B. Lasso analysis is handled by
# the GLMNET package, which has a highly optimized method for searching for the
# optimal lambda. Set lambda to [] to have GLMNET try to figure out lambda for
# you. Otherwise, you can pass your own lambda and do a manual search.
#
# Glmnet for Matlab (2013) Qian, J., Hastie, T., Friedman, J., Tibshirani, R. and Simon, N.
# http://www.stanford.edu/~hastie/glmnet_matlab/
#
# normalize allows you to specify a normalization method to apply to your data
# before fitting models. zscore is recommended (subtract mean and divide by
# standard deviation), but stdev will simply divide by the standard deviation
# without recentering, and 2norm will subtract the mean and divide by the
# 2-norm (which is the euclidean distance between each voxel and the origin).
% endif
bias: 0
lambda: []
normalize: zscore
% elif method=="iterlasso":
# ITERATIVE LASSO
# ===============
regularization: iterlasso_glmnet

# Parameters
# ----------
% if verbose:
# bias toggles whether or not to use a bias unit when fitting models
#
# lambda scales the overall sparsity penalty. N.B. Lasso analysis is handled by
# the GLMNET package, which has a highly optimized method for searching for the
# optimal lambda. Set lambda to [] to have GLMNET try to figure out lambda for
# you. Otherwise, you can pass your own lambda and do a manual search.
#
# Glmnet for Matlab (2013) Qian, J., Hastie, T., Friedman, J., Tibshirani, R. and Simon, N.
# http://www.stanford.edu/~hastie/glmnet_matlab/
#
# normalize allows you to specify a normalization method to apply to your data
# before fitting models. zscore is recommended (subtract mean and divide by
# standard deviation), but stdev will simply divide by the standard deviation
# without recentering, and 2norm will subtract the mean and divide by the
# 2-norm (which is the euclidean distance between each voxel and the origin).
% endif
bias: 0
lambda: []
normalize: zscore
% elif method=="searchlight":
# SEARCHLIGHT
# ===========
searchlight: 0

# Parameters
# ----------
% if verbose:
# See WholeBrain_MVPA/dependencies/searchmight/searchmight.m
# slclassifier expects one of the following values
#  - 'gnb' - a gaussian naive bayes (assuming same variance for both classes)
#  - 'gnb_searchmight' - same, MEX version that runs fast (by far the fastest)
#  - 'lda' - pure LDA
#  - 'lda_ridge' - LDA with a small ridge term
#  - 'lda_shrinkage' - LDA with a shrinkage estimator for the covariance matrix (Strimmer
#  2005; *recommended*)
#  - 'qda_shrinkage' - QDA with same, given that lda_shrinkage is better than the others might
#  as well use it
#  - 'svm_linear'
#  - 'svm_quadratic'
#  - 'svm_sigmoid'
#  - 'svm_rbf'
#
# slpermutations expects one of the following values (see Pereira/Mitchell/Botvinick 2009)
#  - 'accuracyOneSided_analytical' - a simple one-sided binomial test
#  - 'accuracyOneSided_permutation',<nPermutations> - a permutation test
#       (with gnb_searchmight it's feasible to do 100K permutations overnight,
#       all others are way slower)
#
# slpermutations: set to something greater than zero if using accuracyOneSided_permutation.
% endif
slclassifier: "lda_shrinkage"
slradius: [6,9,12,15]
slTestToUse: "accuracyOneSided_analytical"
slpermutations: 0

% elif method=="nrsa":
# Network RSA
# ===========
regularization: L1L2

# Parameters
# ----------
% if verbose:
# bias toggles whether or not to use a bias unit when fitting models
# alpha scales the SOS Lasso penalty associated with picking items from
# different groups.
#
# lambda scales ... (need to remember)
#
# lambda1 scales the overall sparsity penalty.
# LambdaSeq ... (need to remember)
#
# normalize allows you to specify a normalization method to apply to your data
# before fitting models. zscore is recommended (subtract mean and divide by
# standard deviation), but stdev will simply divide by the standard deviation
# without recentering, and 2norm will subtract the mean and divide by the
# 2-norm (which is the euclidean distance between each voxel and the origin).
% endif
bias: 1
normalize: zscore
% if hyperband:
lambda: {'distribution': 'uniform', 'args': [1, 16]}
# Uncomment if using GrOWL
# LambdaSeq: "inf" 
# lambda1: {'distribution': 'uniform', 'args': [1, 16]}
HYPERBAND:
  budget: 100
  aggressiveness: 3
  hyperparameters: ['lambda']
% else:
lambda: []
# lambda1: []
% endif
% endif

# Data and Metadata Paths
# =======================
% if verbose:
# Paths to datasets that you want to fit models to. In the case of SOS Lasso,
# if multiple datasets are passed to a job they are all analyzed at the same
# time. Otherwise, if multiple datasets are passed to a job they are looped
# over, fitting independent models to each subject.
#
# data_var tells the program which variable to read out of each .mat file. Each
# job expects one data_var. You must always set data_var, but it is useful if
# you save multiple matrices within each .mat file. For example, if you
# pre-processed your data in two different ways, you might choose to store each
# dataset as a variable within as single file for the subject, rather than
# saving each to a separate file.
#
# Metadata is the path to your metadata file. The metadata structured array is
# described in the WholeBrain_RSA/demo/demo.m. Each job expects a single
# metadata file.
#
# metadata_var is the same as data_var.
% endif
data:
% for d in data:
  - ${d}
% endfor
data_var: X
metadata: ${metadata}
metadata_var: metadata

# Metadata Field References
# =========================
# K-fold Cross Validation
# -----------------------
% if verbose:
# Cross validation (cv) indexes need to be specified in advance, and stored in
# the metadata structure for each subject under the field 'cvind'. 'cvind' must
# be a item-by-scheme matrix, where each value is a number from 1 to n, where n
# is the highest cv index. A scheme is simply a unique assignement of items to
# cv indexes, in case you want to try different schemes.
#
# Each job expects exactly 1 scheme.
#
# If a list of cvholdout indexes are provided to a single job, then they are
# looped over within the job and produce a separate model for each index
# trained and tested on the appropriate subsets.
#
# Each job expects exactly 1 "finalholdout" index. The final holdout index is
# used during the tuning phase when fitting models are many different parameter
# values. This chunk of the data is completely dropped---it is neither trained
# nor tested on. These chunks are held out so that when you fit "final" models
# with the optimal parameters, there are parts of the data that had nothing to
# do with the parameter selection.
% endif
cvscheme: 1
% if method in ['soslasso','nrsa','searchlightrsa'] and r == 0:
cvholdout:
% for j in range(1,k+1):
  - [${','.join(str(i) for i in range(1,k+1) if not i == j)}]
% endfor
finalholdout: [${','.join(str(i) for i in range(1,k+1))}]
% else:
cvholdout: [${','.join(str(i) for i in range(1,k+1))}]
finalholdout: 0
% endif

# Targets
# -------
% if verbose:
# These fields check against metadata.targets.label and metadata.targets.type,
# respectively, to select the right target. See WholeBrain_MVPA/demo/demo.m for
# how to define targets in the metadata structure.
# Smaller values of tau are associated with higher-dimensional embeddings to
# model. It is a threshold for the reconstruction error.
% endif
% if method in ['soslasso', 'iterlasso', 'lasso', 'searchlight']:
target: faces
target_type: category
% elif method in ['searchlightrsa','nrsa']:
target: "semantic"
target_type: "similarity"
sim_source: "featurenorms"
sim_metric: "cosine"
tau: 0.3
% endif

# Coordinates
# -----------
% if verbose:
# orientation is a way of indicating which set of coordinates should be
# referenced during the analysis. For SOS Lasso the choice of coordinates has
# affects how voxels are grouped. In all cases, this effects which coordinates
# are written out with your results. For SOS Lasso with multiple subjects you
# should use a common space orientation, since voxels are groups both within
# and across subjects. The value provided here is checked against
# metadata.coords.orientation to select the desired coordinates.
% endif
orientation: tlrc

# Filters
# -------
% if verbose:
# filters are ways to subset your data. All filters must be predefined in
# metadata.filters. The values listed here are checked against
# metadata.filters.label. Two filters that apply to the same dimension will be
# combined with AND logic. If you provide a sublist of filters, they are
# combined using OR logic before being combined with the other filters of the
# same dimension.
% endif
filters:
  - rowfilter
  - [colfilterA, colfilterB] # A and B are combined with OR logic
  - colfilterC # The column filter is ultimately C AND (A OR B)

% if method in ['lasso','iterlasso','soslasso','searchlight']:
# WholeBrain_MVPA Options
# =======================
% elif method in ['searchlightrsa','nrsa']:
# WholeBrain_RSA Options
# =======================
% endif
% if verbose:
# SmallFootprint means "do not save model weights or predicted values". This
# might be useful when you are tuning over many, many parameters and you worry
# about running out of disk space.
#
# SaveResultsAs can be set to either mat or json. If json, the results
# structure is serialized and written to json-formatted text.
#
# subject_id_fmt tells the program how to determine the subject id from your
# data file naming convention. Internally, the program will extract the subject
# id from the filename using sscanf which is a MATLAB builtin. So experiment
# with sscanf to come up with the right format string for your needs, and then
# put that format string here.
#
# If you are not running on HTCondor, you can drop the executable and wrapper
# lines.
% endif
SmallFootprint: 0
SaveResultsAs: mat
subject_id_fmt: s%d.mat
% if method in ['lasso','iterlasso','soslasso','searchlight']:
executable: "${HOME}/src/WholeBrain_MVPA/bin/WholeBrain_MVPA"
wrapper: "${HOME}/src/WholeBrain_MVPA/run_WholeBrain_MVPA.sh"
% elif method in ['searchlightrsa','nrsa']:
executable: "${HOME}/src/WholeBrain_RSA/bin/WholeBrain_RSA"
wrapper: "${HOME}/src/WholeBrain_RSA/run_WholeBrain_RSA.sh"
% endif
% if r > 0:
RandomSeed: [${','.join(str(i) for i in range(1,r+1))}]
PermutationTest: True
PermutationMethod: 'simple'
RestrictPermutationsByCV: false
% endif

# condortools/setupJob Options
# ============================
% if verbose:
# EXPAND: Accepts fields that contain a list. Each element in the list will be
# assigned to a separate job. If multiple fields are provided to EXPAND, their
# lists are crossed. Fields nested in sublists under EXPAND are linked.
#
# Example 1:
# a: [1,2]
# b: [1,2]
# EXPAND: [a,b]
# ==> 4 jobs, a=1,b=1; a=1,b=2; a=2,b=1; a=2,b=2.
#
# Example 2:
# a: [1,2]
# b: [1,2]
# EXPAND: [[a,b]]
# ==> 2 jobs, a=1,b=1; a=2,b=2.
#
# Example 3:
# a: [1,2]
# b: [1,2]
# EXPAND: []
# ==> 1 jobs, a=[1,2],b=[1,2].
#
# COPY and URLS: Both expect fields that contain a file path or list of file
# paths. Files are either copied into the job file structure or written into a
# URLS file (which are referenced on the execute-node of a distributed job to
# retrieve files from a proxy server). These operations happen after EXPAND
# takes effect, so lists of files can be distributed to specific jobs.
% endif
EXPAND:
  - data
  - [finalholdout, cvholdout]
% if r > 0:
  - RandomSeed
% endif
% if verbose:
# If you are not running on HTCondor, you can replace the following with:
# COPY: []
# URLS: []
# or remove them all together.
% endif
COPY:
  - executable
  - wrapper
URLS:
  - data
  - metadata