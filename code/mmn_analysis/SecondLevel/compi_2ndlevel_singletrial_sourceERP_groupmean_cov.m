function compi_2ndlevel_singletrial_sourceERP_groupmean_cov(scndlvlroot, imagePaths, options, covars)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_SOURCEERP_GROUPMEAN_COV Computes 1st level 
% statistics for multiple regression of the EEG signal with single-trial 
% (modelbased) regressors, using a one-sample t-test for source analysis.
% Computes an F-contrast per (modelbased) single-trial regressor on the
% first level and saves the SPM.mat, the conimages and a results report
% (pdf) per regressor in the factorial design directory.
%
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           imagePaths      - name and path (string) of the beta images
%           options         - the struct that holds all analysis options
%           covars          - covariates (table) for all subjects
%   OUT:    --
%--------------------------------------------------------------------------

% Adapted from: TNUEEG_2NDLEVEL_SINGLETRIAL_GROUPMEAN

%% Main 

% how many subjects do we use
nSubjects = numel(imagePaths);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

VOI    = getfield(load(options.eeg.source.mmnVOI), 'VOI');
regressors = options.eeg.erp.regressors;

for reg = 1: numel(regressors)
    regressorName = char(regressors{reg});

    for i_source = 1: size(VOI, 1)
        label = VOI{i_source, 1};

        % open a new results folder for each regressor and source
        factorialDesignDir = fullfile(scndlvlroot, regressorName, label);
        if ~exist(factorialDesignDir, 'dir')
            mkdir(factorialDesignDir);
        end
    
        % collect the regressor's source beta image from each subject
        scans = cell(nSubjects, 1);
    
        switch options.eeg.erp.type
            case {'oddball'}
                for sub = 1: nSubjects
                    scans{sub, 1} = char(fullfile(imagePaths{sub}, ['source_' label '_' regressorName], ...
                        'smoothed_condition_mmn.nii,1'));
                end
        end

        % create and run the job - one test per regressor
        job = compi_getjob_2ndlevel_onesample_ttest_cov(factorialDesignDir, scans, regressorName, covars);
        
        spm_jobman('run', job);

    end
end

end