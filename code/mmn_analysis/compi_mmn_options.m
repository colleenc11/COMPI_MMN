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

%% Task-specific options
% switch task
%     case 'ioio'
%         % Specify task options
%         options = compi_ioio_task_options(options);
% end
% 
% % Specify behavioral options
% options = compi_ioio_behav_options(options);

% Specify HGF options
% switch modality
%     case 'hgf_comp'
%         model_space = 9;
%     case 'phase'
%         model_space = 9;
%     otherwise
%         model_space = 9;
% end
% options = compi_ioio_hgf_options(options, model_space);


%% Specify EEG options
% switch options.task.modality
%     case 'eeg'
%         switch task
%             case 'ioio'
%                 options = compi_ioio_eeg_options(options, ...
%                     preprocStrategyValueArray, firstLevelDesignName);
%             case 'mmn'
%                 options = compi_mmn_eeg_options(options, ...
%                     preprocStrategyValueArray);
%         end
% end

options = compi_mmn_eeg_options(options, preprocStrategyValueArray);

%% Get subjects
% Enter new subjects here, include in missingness switch and eeg first flag
options = compi_ioio_subject_options(options);



