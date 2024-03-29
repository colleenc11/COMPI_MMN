function compi_2ndlevel_singletrial_source_groupmean_cov(scndlvlroot, imagePaths, options, covars)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_SOURCE_GROUPMEAN_COV Computes an F-contrast 
% per source and per (modelbased) single-trial regressor on the 
% first level and saves the SPM.mat, the conimages and a results report 
% (pdf) per regressor in the factorial design directory.
% 
%   IN:     scndlvlroot     - directory (string) for saving the SPM.mat
%           imagePaths      - name and path (string) of the beta images
%           options         - struct with all analysis options
%           covars          - covariates for all subjects
%   OUT:    --
% 
% Adapted from: TNUEEG_2NDLEVEL_SINGLETRIAL_GROUPMEAN
%--------------------------------------------------------------------------

% Adapted from: TNUEEG_2NDLEVEL_SINGLETRIAL_GROUPMEAN

%% Main 

% how many subjects do we use
nSubjects = numel(imagePaths);

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

VOI    = getfield(load(options.eeg.source.VOI), 'VOI');
regressors = options.eeg.stats.regressors;

% loop through regressors
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
    
        switch options.eeg.stats.design
            case {'epsilons', 'lowPE', 'highPE'}
                for sub = 1: nSubjects
                    scans{sub, 1} = char(fullfile(imagePaths{sub}, options.eeg.stats.design, label, ['beta_000' num2str(reg+1) '.nii,1']));
                end
            otherwise
                for sub = 1: nSubjects
                    scans{sub, 1} = char(fullfile(imagePaths{sub}, regressorName, label, ['beta_0002.nii,1']));
                end
        end

        % create and run the job - one test per regressor
        job = compi_getjob_2ndlevel_onesample_ttest_cov(factorialDesignDir, scans, regressorName, covars);
        
        spm_jobman('run', job);

    end
end

end