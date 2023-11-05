function compi_2ndlevel_erpstats_groupmean( scndlvlroot, imagePaths, factorName, covars, options )
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_ERPSTATS_GROUPMEAN Computes 2nd level statistics for a 
% classical ERP analysis using a one-sample t-test. Saves the SPM.mat, 
% the conimages and a results report (pdf) in the scndlvlroot.
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           imagePaths      - cell array of paths (strings) of the images
%           factorName      - a string with the name of the condition or
%                           factor (needs to be the same as the condition 
%                           name in the smoothed images)
%           covars          - a table with covariates of interest
%           options         - the struct that holds all analysis options
%   OUT:    --
% 
% Adapted from TNUEEG_2NDLEVEL_ERPSTATS_GROUPMEAN
%--------------------------------------------------------------------------

% how many subjects do we use
nSubjects = numel(imagePaths);
scans = cell(nSubjects, 1);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% collect the smoothed image from each subject
switch factorName
    
    case {'oddball_stable', 'oddball_volatile'}
        for sub = 1: nSubjects
            scans{sub, 1} = fullfile(imagePaths{sub, 1}, factorName, ['sensor_diff_' factorName], 'smoothed_condition_diff.nii,1');
        end

        job = compi_getjob_2ndlevel_onesample_ttest_cov(scndlvlroot, scans, factorName, covars);
        spm_jobman('run', job);
        clear job;
        close all;

    case 'oddball'
        % difference wave analysis (w/ covariates)
        for sub = 1: nSubjects
            scans{sub, 1} = fullfile(imagePaths{sub}, factorName, ['sensor_diff_' factorName], 'smoothed_condition_diff.nii,1');
        end

        scndlvlroot_diffwave = fullfile(scndlvlroot, 'diffwave');
        job = compi_getjob_2ndlevel_onesample_ttest_cov(scndlvlroot_diffwave, scans, factorName, covars);
        spm_jobman('run', job);
        clear job;

        % stable vs. volatile difference wave analysis (no covariates)
        if ~options.eeg.covar.include 
            phase_cond = {'oddball_stable', 'oddball_volatile'};
            for i_group = 1: numel(options.subjects.group_labels) 
                if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
                    for sub = 1: numel(options.subjects.IDs{i_group})
                        pairs_phase(sub).scans{1, 1} = fullfile(imagePaths{sub, 1}, phase_cond{1}, ['sensor_diff_' phase_cond{1}], 'smoothed_condition_diff.nii,1');
                        pairs_phase(sub).scans{2, 1} = fullfile(imagePaths{sub, 1}, phase_cond{2}, ['sensor_diff_' phase_cond{2}], 'smoothed_condition_diff.nii,1');
                    end
                end
            end
    
            scndlvlroot_phase = fullfile(scndlvlroot, 'diffwave_phase');
            job = compi_getjob_2ndlevel_anova_within(scndlvlroot_phase, pairs_phase, factorName, phase_cond{1}, phase_cond{2});
            spm_jobman('run', job);
            clear job;
        end

    otherwise
        for sub = 1: nSubjects
            scans{sub, 1} = fullfile(imagePaths{sub}, factorName, ['sensor_diff_' factorName], 'smoothed_condition_diff.nii,1');
        end

        job = compi_getjob_2ndlevel_onesample_ttest_cov(scndlvlroot, scans, factorName, covars);
        spm_jobman('run', job);
end

end