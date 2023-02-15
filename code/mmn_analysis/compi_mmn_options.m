function options = compi_mmn_options(preprocStrategyValueArray, firstLevelDesignName)
%--------------------------------------------------------------------------
% Function decription goes here.
%
%--------------------------------------------------------------------------

%% Defaults
if nargin < 1
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

if nargin < 2
    firstLevelDesignName = 'Default';
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

options.analysis.type = 'all'; % 'hc', 'matched', 'all'
options.task.modality = 'eeg';  

%% Set up task-specific roots
% Result folder roots
options = compi_setup_roots(preprocStrategyValueArray, options);

%% MMN specific options
options = compi_mmn_eeg_options(options, preprocStrategyValueArray);

%% Get subjects
% Enter new subjects here, include in missingness switch and eeg first flag
options = compi_ioio_subject_options(options);



