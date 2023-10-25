function compi_2ndlevel_erpstats_groupdiff(options)
%--------------------------------------------------------------------------
% Computes the second level contrast images for differences in the COMPI
% study effect between conditions.
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

% general analysis options
if nargin < 1
    options = compi_ioio_options;
end


%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_erpgroupdiffstats_%s')));

factorNames = options.eeg.erp.regressors;


% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% Create imagePaths based on # of groups and conditions
nSubjects = max(cellfun(@length, options.subjects.IDs));
imagePaths = cell(nSubjects, length(options.subjects.group_labels));

try
    % check for previous statistics
    spmFile = fullfile(options.roots.erp, 'groupdiff', ...
        factorNames{1}, 'SPM', 'SPM.mat');
    load(spmFile);
    disp(['Group difference stats for ' factorNames{i_reg} ...
        ' ERPs have been computed before.']);
    if options.eeg.erp.overwrite
        delete(spmFile);
        disp('Overwriting...');
        error('Continue to drug difference ERP step');
    else
        disp('Nothing is being done.');
    end
catch

    for i_reg = 1:numel(factorNames)

        disp(['Computing group difference stats for ' factorNames{i_reg}  ' ERPs...']);

        % get covaiates for both groups
        if options.eeg.covar.include
            covars = compi_get_covariates(options, options.subjects.all);
        else
            covars = {};
        end

        % make sure we have a results directory
        scndlvlroot = fullfile(options.roots.erp, 'groupdiff', ...
            factorNames{i_reg}, 'SPM');
        
        if ~exist(scndlvlroot, 'dir')
            mkdir(scndlvlroot);
        end

        % collect the smoothed image from each subject
        switch factorNames{i_reg}

            case 'oddball_phases'

                % smoothed images of averaged ERP data for each subject in each group 
                % and in each phase serve as input to 2nd level statistics
                % Groups may be different sizes - need to find max size

                % stable MMN analysis         
                for i_group = 1: numel(options.subjects.group_labels)
                    for sub = 1: length(options.subjects.IDs{i_group})
                        subID = char(options.subjects.IDs{i_group}{sub});
                        details = compi_get_subject_details(subID, options);
        
                        imagePaths{sub, i_group} = fullfile(details.eeg.erp.root, factorNames{i_reg}, ...
                                                 ['sensor_diff_stable_' factorNames{i_reg}], ...
                                                 ['smoothed_condition_mmn.nii,1']);
                    end
                end

                scndlvlroot_stable = fullfile(scndlvlroot, 'stable');
                job = compi_oneway_anova(imagePaths, scndlvlroot_stable, covars, options);
                spm_jobman('run',job);
                clear job;


                % volatile MMN analysis         
                for i_group = 1: numel(options.subjects.group_labels)
                    for sub = 1: length(options.subjects.IDs{i_group})
                        subID = char(options.subjects.IDs{i_group}{sub});
                        details = compi_get_subject_details(subID, options);
        
                        imagePaths{sub, i_group} = fullfile(details.eeg.erp.root, factorNames{i_reg}, ...
                                                 ['sensor_diff_volatile_' factorNames{i_reg}], ...
                                                 ['smoothed_condition_mmn.nii,1']);
                    end
                end

                scndlvlroot_volatile = fullfile(scndlvlroot, 'volatile');
                job = compi_oneway_anova(imagePaths, scndlvlroot_volatile, covars, options);
                spm_jobman('run',job);
                clear job;

            otherwise
                for i_group = 1: numel(options.subjects.group_labels)
                    for sub = 1: length(options.subjects.IDs{i_group})
                        subID = char(options.subjects.IDs{i_group}{sub});
                        details = compi_get_subject_details(subID, options);
     
                        imagePaths{sub, i_group} = fullfile(details.eeg.erp.root, factorNames{i_reg}, ...
                                                 ['sensor_diff_' factorNames{i_reg}], ...
                                                 ['smoothed_condition_mmn.nii,1']);
                    end
                end

                job = compi_oneway_anova(imagePaths, scndlvlroot, covars, options);
                spm_jobman('run',job);
                clear job;
        end
        
        disp(['Computed 2nd-level group difference statistics for ' ...
            factorNames{i_reg} ' ERPs.']);
    end
end
cd(options.roots.results);

diary OFF
end