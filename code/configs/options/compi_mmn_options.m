function options = compi_mmn_options(preprocStrategyValueArray)
%--------------------------------------------------------------------------
% Options for COMPI MMN study (directory roots, analysis, subejcts)
% IN
%       preprocStrategyValueArray     preprocessing analysis options
%--------------------------------------------------------------------------

%% Defaults
if nargin < 1
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

%% Set user roots
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Colleen
    case 'colleenc'
        options.roots.project = '/Volumes/Seagate2TB/COMPI_MMN';
        options.roots.data    = '/Volumes/Seagate2TB/COMPI_MMN/data';
        options.roots.code    = '/Users/colleenc/CAMH/COMPI_MMN/code/';
        options.roots.config  = '/Users/colleenc/CAMH/COMPI_MMN/code/configs';
end

options.roots.toolboxes = fullfile(options.roots.code ,'Toolboxes');

%% Set options

options.analysis.type    = 'HC'; % Type of group analysis (we only have HCs)

options.eeg.stats.design = 'epsilons';

options.eeg.stats.design_types  = {'epsilons', 'lowPE', 'highPE'};
options.eeg.erp.design_types    = {'oddball', 'oddball_stable', 'oddball_volatile'};

% 2nd-level analysis
options.eeg.type            = 'sensor';     % Type of 2nd-level analysis (sensor, source)
options.eeg.covar.include   = 0;            % Include covariates in analysis (1 = yes, 0 = no)

%% Set up task-specific roots
options = compi_setup_roots(preprocStrategyValueArray, options);

%% Get subjects
% Enter new subjects here, include in missingness switch and eeg first flag
options = compi_mmn_subject_options(options);

%% EEG specific options

% Single-subject analysis pipeline
options = compi_mmn_analysis_pipeline(options);

% Preprocessing, options, including image conversion
options = compi_mmn_preprocessing_options(preprocStrategyValueArray, options);

% ERP 2nd-level options
options = compi_mmn_erp_options(options);

% Model-based 2nd-level options (sensor and source)
options = compi_mmn_stats_options(options);

%% Additional analysis files
options.eeg.montage     = fullfile(options.roots.config, 'COMPI_montage.mat');
options.eeg.eegtemplate = fullfile(options.roots.config, 'COMPI_64ch.sfp');
options.eeg.eegchannels = fullfile(options.roots.config, 'compi_eeg_channels.mat');

options.eeg.covar.file = fullfile(options.roots.data, 'clinical', 'input_mask_LM.xlsx');





