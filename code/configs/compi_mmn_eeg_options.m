function [options] = compi_mmn_eeg_options(options, preprocStrategyValueArray)
%--------------------------------------------------------------------------
% COMPI_MMN_EEG_OPTIONS EEG analysis options for COMPI MMN study.
% IN
%       options                     (subject-independent) analysis pipeline 
%                                   options, retrieve via options = 
%                                   compi_set_analysis_options
%       preprocStrategyValueArray   preprocessing analysis options
%--------------------------------------------------------------------------

%% Single-subject analysis pipeline

compi_mmn_analysis_pipeline(options);

%% Preprocessing

% preprocessing options, including image conversion
options = compi_mmn_preprocessing_options(preprocStrategyValueArray, options);

%% ERP 2nd-level

options = compi_mmn_erp_options(options);

%% Model-based 2nd-level Statistics

% sensor and source analysis options
options = compi_mmn_stats_options(options);

%% Additional analysis files
options.eeg.montage     = fullfile(options.roots.config, 'COMPI_montage.mat');
options.eeg.eegtemplate = fullfile(options.roots.config, 'COMPI_64ch.sfp');
options.eeg.eegchannels = fullfile(options.roots.config, 'compi_eeg_channels.mat');

options.eeg.covar.file = fullfile(options.roots.data, 'clinical', 'input_mask_LM.xlsx');

