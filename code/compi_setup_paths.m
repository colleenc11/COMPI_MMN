function compi_setup_paths()
% -------------------------------------------------------------------------
% COMPI_SETUP_PATHS restores default paths, add project paths including 
% SPM (but without sub-folders), sets up batch editor
%
% Author:   Lars Kasper
% Created:  2018-02-05
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
% -------------------------------------------------------------------------

warning('off','all')

pathProject = fileparts(mfilename('fullpath'));

% remove all other toolboxes
restoredefaultpath;

% add project path with all sub-paths
addpath(genpath(pathProject));

%% remove SPM subfolder paths 
% NOTE: NEVER add SPM with subfolders to your path, since it creates
% conflicts with Matlab core functions, e.g., uint16

pathSpm = fileparts(which('spm'));
% remove subfolders of SPM, since it is recommended,
% and fieldtrip creates conflicts with Matlab functions otherwise
rmpath(genpath(pathSpm));
addpath(pathSpm);

% initalize spm with reasonable parameters
compi_setup_spm();

rmpath(genpath(fullfile(pathProject,'Toolboxes', 'tapas_6.0')));

warning('on','all')

