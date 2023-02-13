function compi_2ndlevel_erpstats_groupmean( scndlvlroot, imagePaths, factorName, covars, options )
% COMPI_2NDLEVEL_ERPSTATS_GROUPMEAN Computes 2nd level statistics for a classical
% ERP analysis using a one-sample t-test.
%   Computes a one-sample t-test on the second level and saves the SPM.mat,
%   the conimages and a results report (pdf) in the scndlvlroot.
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           imagePaths      - cell array of paths (strings) of the images
%           factorName      - a string with the name of the condition or
%                           factor (needs to be the same as the condition 
%                           name in the smoothed images)
%   OUT:    --

% Adapted from TNUEEG_2NDLEVEL_ERPSTATS_GROUPMEAN

% how many subjects do we use
nSubjects = numel(imagePaths);
scans = cell(nSubjects, 1);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% collect the smoothed image from each subject
switch factorName
    
    case 'oddball_phases'

        % difference wave analysis
        phase_cond = {'standStab', 'standVol', 'devStab', 'devVol'};
        for i_group = 1: numel(options.subjects.group_labels) 
            if strcmp(options.subjects.group_labels{i_group}, options.condition)
                for sub = 1: numel(options.subjects.IDs{i_group})
                    pairs(sub).scans{1, 1} = fullfile(imagePaths{sub, 1}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{1} '.nii,1']);
                    pairs(sub).scans{2, 1} = fullfile(imagePaths{sub, 1}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{2} '.nii,1']);
                    pairs(sub).scans{3, 1} = fullfile(imagePaths{sub, 1}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{3} '.nii,1']);
                    pairs(sub).scans{4, 1} = fullfile(imagePaths{sub, 1}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{4} '.nii,1']);
                end
            end
        end

        job = compi_getjob_2ndlevel_anova_within_phase(scndlvlroot, pairs, factorName, phase_cond);
        spm_jobman('run', job);

        clear job;
        close all;

        % difference wave analysis
        phase_cond = {'stableMMN', 'volatileMMN'};
        for i_group = 1: numel(options.subjects.group_labels) 
            if strcmp(options.subjects.group_labels{i_group}, options.condition)
                for sub = 1: numel(options.subjects.IDs{i_group})
                    pairs_diff(sub).scans{1, 1} = fullfile(imagePaths{sub, 1}, ['sensor_diff_stable_' factorName], 'smoothed_condition_mmn.nii,1');
                    pairs_diff(sub).scans{2, 1} = fullfile(imagePaths{sub, 1}, ['sensor_diff_volatile_' factorName], 'smoothed_condition_mmn.nii,1');
                end
            end
        end

        scndlvlroot_diffwave = fullfile(scndlvlroot, 'diffwave');
        job = compi_getjob_2ndlevel_anova_within(scndlvlroot_diffwave, pairs_diff, factorName, phase_cond{1}, phase_cond{2});
        spm_jobman('run', job);
        clear job;
        close all;
    
    case 'oddball'
        % standard / deviant analysis
        phase_cond = {'standard', 'deviant'};
        for i_group = 1: numel(options.subjects.group_labels) 
            if strcmp(options.subjects.group_labels{i_group}, options.condition)
                for sub = 1: numel(options.subjects.IDs{i_group})
                    pairs(sub).scans{1, 1} = fullfile(imagePaths{sub}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{1} '.nii,1']);
                    pairs(sub).scans{2, 1} = fullfile(imagePaths{sub}, ['sensor_' factorName], ['smoothed_condition_' phase_cond{2} '.nii,1']);
                end
            end
        end

        job = compi_getjob_2ndlevel_anova_within(scndlvlroot, pairs, factorName, phase_cond{1}, phase_cond{2});
        %job = tnueeg_getjob_2ndlevel_paired_ttest(scndlvlroot, pairs, factorName, phase_cond{1}, phase_cond{2});
        spm_jobman('run', job);

        clear job;

        % difference wave analysis
        for sub = 1: nSubjects
            scans{sub, 1} = fullfile(imagePaths{sub}, ['sensor_diff_' factorName], 'smoothed_condition_mmn.nii,1');
        end

        scndlvlroot_diffwave = fullfile(scndlvlroot, 'diffwave');
        job = compi_getjob_2ndlevel_onesample_ttest_cov(scndlvlroot_diffwave, scans, [factorName '_mmn'], covars);
        spm_jobman('run', job);
        
    otherwise
        for sub = 1: nSubjects
            scans{sub, 1} = fullfile(imagePaths{sub}, 'smoothed_condition_mmn.nii,1');
        end

        job = compi_getjob_2ndlevel_onesample_ttest_cov(scndlvlroot, scans, [factorName '_mmn'], covars);
        spm_jobman('run', job);
end

end