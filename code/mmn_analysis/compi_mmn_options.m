function options = compi_mmn_options(task, modality, groups, preprocStrategyValueArray, firstLevelDesignName)
%--------------------------------------------------------------------------
% Function decription goes here.
%
%--------------------------------------------------------------------------

%% Defaults
if nargin < 1
    % Choose between: 'mmn', 'ioio', 'wm'
    task = 'mmn';
end

if nargin < 2
    % Choose between: 'eeg','fmri', 'behav' (only behavior from first task,
    % if applicable), 'behav_all', 'phase', 'hgf_comp'
    modality = 'eeg';
end

if nargin < 3
    % Choose between: 'all', 'hc', 'fep', 'chr'
    groups = 'all';
end

if nargin < 4
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

if nargin < 5
    firstLevelDesignName = 'Default';
end


%% Set user roots
[~, uid] = unix('whoami');
switch uid(1: end-1)
    
    % Colleen
    case 'colleenc'
        options.roots.project = '/Volumes/Seagate2TB/COMPI_MMN';
        options.roots.code    = '/Volumes/Seagate2TB/COMPI_MMN/code';
        options.roots.config  = '/Volumes/Seagate2TB/COMPI_MMN/code/configs';
        options.roots.data    = '/Volumes/Seagate2TB/COMPI_MMN/data';
end

options.roots.toolboxes = fullfile(options.roots.code ,'Toolboxes');

%% Set options
% Choose between: 'all', 'hc', 'fep', 'chr'
options.subjects.groups = groups; 

% Choose between: 'mmn', 'ioio', 'wm'
options.task.type = task;

% Choose between: 'eeg','fmri', 'phase' (only behavior from first task, 
% if applicable), 'learning_effects'
options.task.modality = modality;  

%% Set up task-specific roots
% Result folder roots
options = compi_setup_roots(task, modality, preprocStrategyValueArray, options);

%% Task-specific options
switch task
    case 'ioio'
        % Specify task options
        options = compi_ioio_task_options(options);
end

% Specify behavioral options
options = compi_ioio_behav_options(options);

% Specify HGF options
switch modality
    case 'hgf_comp'
        model_space = 9;
    case 'phase'
        model_space = 9;
    otherwise
        model_space = 9;
end
options = compi_ioio_hgf_options(options, model_space);


%% Specify EEG options
switch options.task.modality
    case 'eeg'
        switch task
            case 'ioio'
                options = compi_ioio_eeg_options(options, ...
                    preprocStrategyValueArray, firstLevelDesignName);
            case 'mmn'
                options = compi_mmn_eeg_options(options, ...
                    preprocStrategyValueArray);
        end
end


%% Get subjects
% Enter new subjects here, include in missingness switch and eeg first flag
options = compi_ioio_subject_options(options);



