function compi_2ndlevel_singletrial_groupmean_cov( scndlvlroot, imagePaths, options, covars)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_GROUPMEAN_COV Computes an F-contrast per 
% (modelbased) single-trial regressor on the first level and saves the 
% SPM.mat, the conimages and a results report (pdf) per regressor in the 
% factorial design directory.
% 
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           imagePaths      - name and path (string) of the beta images
%           options         - struct with all analysis options
%           covars          - covariates for all subjects
%   OUT:    --
% 
% Adapted from: TNUEEG_2NDLEVEL_SINGLETRIAL_GROUPMEAN
%--------------------------------------------------------------------------

%% Main 

% how many subjects do we use
nSubjects = numel(imagePaths);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

regressors  = options.eeg.stats.regressors;

% loop through regressors
for reg = 1: numel(regressors)
    regressorName = char(regressors{reg});
    
    % open a new folder for each regressor
    factorialDesignDir = fullfile(scndlvlroot, regressorName);
    if ~exist(factorialDesignDir, 'dir')
        mkdir(factorialDesignDir);
    end
    
    % collect the regressor's beta image from each subject
    scans = cell(nSubjects, 1);

    for sub = 1: nSubjects
        scans{sub, 1} = char(fullfile(imagePaths{sub}, ['beta_000' num2str(reg+1) '.nii,1']));
    end

    % create and run the job - one test per regressor
    job = compi_getjob_2ndlevel_onesample_ttest_cov(factorialDesignDir, scans, regressorName, covars);

    spm_jobman('run', job);

end

end