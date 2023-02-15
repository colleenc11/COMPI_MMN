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

options.analysis.type       = 'matched';    % Type of group analysis (hc, matched, all)

% 2nd-level analysis
options.eeg.type            = 'source';     % Type of 2nd-level analysis (sensor, source)
options.eeg.covars          = 1;            % Include covariates in analysis (1 = yes, 0 = no)

% 2nd-level design
options.eeg.stats.design    = 'epsilon';    % epsilon, lowPE, highPE
options.eeg.erp.type        = 'oddball';    % epsilon, oddball, oddball_phases

%% Set up task-specific roots
options = compi_setup_roots(preprocStrategyValueArray, options);

%% MMN specific options
options = compi_mmn_eeg_options(options, preprocStrategyValueArray);

%% Get subjects
% Enter new subjects here, include in missingness switch and eeg first flag
options = compi_ioio_subject_options(options);



