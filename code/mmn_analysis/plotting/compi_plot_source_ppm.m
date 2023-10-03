function compi_plot_source_ppm(timewindow, regressor, options)
%-----------------------------------------------------------------------
% COMPI_PLOT_SOURCE_PPM Calculate posterior parameteric map averaged across
% all subjects for a specific timewindow. Save final result as image. 
%   IN:     timewindow - timewindow to average PPM across
%           regressor  - string of factor name
%           options    - the struct that holds all analysis options
%   OUT:    --
%-----------------------------------------------------------------------

% general analysis options
if nargin < 1
    options = compi_mmn_options;
end

disp(['Computing source stats for time range...' ...
    num2str(timewindow(1)) '-' num2str(timewindow(2))]);

% make sure we have a results directory
scndlvlroot = fullfile(options.roots.results_source, options.condition, ...
    'Figures');

if ~exist(scndlvlroot, 'dir')
    mkdir(scndlvlroot);
end

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% for each subject, calculate average PPM across time window and save as
% image
for i_group = 1: numel(options.subjects.group_labels)
   
    if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
        nSubjects = numel(options.subjects.IDs{i_group});
        prepPaths = cell(nSubjects, 1);
        for sub = 1: nSubjects
            subID = char(options.subjects.IDs{i_group}{sub});
            details = compi_get_subject_details(subID, options);

            if startsWith(regressor, 'oddball')
                prepPaths{sub, 1} = fullfile(details.eeg.erp.root, regressor, ['diff_' regressor '.mat']);
            else
                prepPaths{sub, 1} = details.eeg.prepfile;
            end
        end
    end

    prepPaths = cellstr(prepPaths);

    job = compi_getjob_source_ppm(timewindow, prepPaths);
    spm_jobman('run', job);
    clear job;
end

% calculate mean image averaged across all subejcts
for i_group = 1: numel(options.subjects.group_labels)
   
    if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
        nSubjects = numel(options.subjects.IDs{i_group});
        imgPaths = cell(nSubjects, 1);
        for sub = 1: nSubjects
            subID = char(options.subjects.IDs{i_group}{sub});
            details = compi_get_subject_details(subID, options);

            if startsWith(regressor, 'oddball')
                imgPaths{sub, 1} = fullfile(details.eeg.erp.root, regressor,...
                    ['diff_' regressor '_1_t' num2str(timewindow(1)) '_' num2str(timewindow(2)) '_f_1.nii,1']);
            else
                imgPaths{sub, 1} = fullfile(details.eeg.preproot,...
                    [subID '_outcomes_1_t' num2str(timewindow(1)) '_' num2str(timewindow(2)) '_f_1.nii,1']);
            end
        end
    end

    imgPaths = cellstr(imgPaths);

    fileName = ['avg_source_' regressor '_t' num2str(timewindow(1)) '_' num2str(timewindow(2))];
    
    job = compi_getjob_imcalc_source(imgPaths, fileName, scndlvlroot);
    spm_jobman('run', job);
    clear job;
end
        