function [options] = compi_mmn_stats_options(options)
%--------------------------------------------------------------------------
% COMPI_MMN_STATS_OPTIONS 2nd-level options for sensor and source analysis.
% IN
%       options       (subject-independent) analysis pipeline options
%                     options = compi_set_analysis_options
%--------------------------------------------------------------------------

%% EEG Sensor Analysis----------------------------------------------------%
options.eeg.stats.firstLevelAnalysisWindow = [100 400];
options.eeg.stats.priors        = 'volTrace';           % omega35, default, mypriors, kappa2, peIncrease, volTrace
options.eeg.stats.designPruned  = true;                 % if true, rejected trials are removed from conversion and design matrix

options.eeg.stats.pValueMode    = 'clusterFWE';
options.eeg.stats.exampleID     = '0001';
options.eeg.stats.overwrite     = 1;

%% EEG Source Analysis----------------------------------------------------%
options.eeg.source.firstLevelAnalysisWindow = [100 400];

options.eeg.source.msp            = true;
options.eeg.source.doVisualize    = false;
% options.eeg.source.type           = 'source';

% source inversion
options.eeg.source.VOI            = fullfile(options.roots.config, 'compi_voi_msp_mmn.mat');
options.eeg.source.invtype        = 'MSP'; %GS, IID
options.eeg.source.freqOfInterest = [0 512]; %256
options.eeg.source.radiusInvert   = 32; % radius of source cluster
options.eeg.source.priorsmask     = {''};

% source extraction
options.eeg.source.radiusExtract  = 16;

% source labels
options.eeg.source.exampleLabel   = 'MSP_leftA1';
options.eeg.source.labels         = {'MSP_leftA1', 'MSP_rightA1', 'MSP_leftSTG', 'MSP_rightSTG', 'MSP_leftIFG', 'MSP_rightIFG'};
options.eeg.source.overwrite      = 1;
end