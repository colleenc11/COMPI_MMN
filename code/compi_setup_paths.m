function output = compi_setup_paths()
% restores default paths, add project paths including SPM (but without
% sub-folders), sets up batch editor
%
%
% EXAMPLE
%   dmpad_setup_paths
%
% Author:   Lars Kasper
% Created:  2018-02-05
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich


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

compi_setup_spm();

rmpath(genpath(fullfile(pathProject,'Toolboxes', 'tapas_6.0')));
rmpath(genpath(fullfile(pathProject,'Toolboxes', 'HGF_3.0')));

rmpath(genpath(fullfile(pathProject,'behav','FirstLevel','hgf','utils','HGF_tutorial')));

