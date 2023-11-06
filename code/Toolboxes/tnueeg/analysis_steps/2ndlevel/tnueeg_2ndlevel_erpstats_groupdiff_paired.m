function tnueeg_2ndlevel_erpstats_groupdiff_paired( scndlvlroot, imagePaths, factorName, grouplabels )
%TNUEEG_2NDLEVEL_ERPSTATS_GROUPDIFF_PAIRED Computes statistics for differences
%in the effect of some factor between conditions or time points in a 
%within-subject design, or between paired groups, using a paired t-test.
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           betaImages      - name and path (string) of the beta images
%           regressors      - a cell array list of regressor names
%                           (strings)
%           conditions      - a 2x1 cell array list of condition names
%   OUT:    --

% how many subjects do we use
nSubjects = size(imagePaths, 1);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% collect the smoothed image from each subject in each condition
for sub = 1: nSubjects
    pairs(sub).scans{1, 1} = fullfile(imagePaths{sub, 1}, ['smoothed_condition_' factorName '.nii,1']);
    pairs(sub).scans{2, 1} = fullfile(imagePaths{sub, 2}, ['smoothed_condition_' factorName '.nii,1']);
end

% group labels
group1 = char(grouplabels{1});
group2 = char(grouplabels{2});

% create and run the job - one test per regressor
job = tnueeg_getjob_2ndlevel_paired_ttest(scndlvlroot, pairs, factorName, group1, group2);
spm_jobman('run', job);

end