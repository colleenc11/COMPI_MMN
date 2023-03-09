function compi_2ndlevel_erpsource_percondition(options)
%COMPI_2NDLEVEL_ERPSTATS_PERCONDITION Computes the second level contrast
%images for high and low ERP effects in one condition in the MNCHR study.
%   IN:     options - the struct that holds all analysis options
%   OUT:    --

% general analysis options
if nargin < 1
    options = mnCHR_set_analysis_options;
end

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_erpsource_%s')));

%%% TO FIX %%%
try
    % check for previous statistics
    spmFile = fullfile(options.roots.results_source, options.condition, ...
        options.eeg.erp.regressors{1}, options.eeg.source.exampleLabel, 'SPM.mat');
    load(spmFile);
    disp(['Group stats for difference waves of ' factorNames{end} ...
        ' ERPs have been computed before.']);
    if options.eeg.source.overwrite
        delete(fullfile(options.roots.results_source, options.condition, ...
            options.eeg.erp.regressors{1}, options.eeg.source.exampleLabel, 'SPM.mat'));
        disp('Overwriting...');
        error('Continue to 2nd level stats step');
    else
        disp('Nothing is being done.');
    end
catch

    disp(['Computing 2nd level source stats for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.erp.type ' design...']);
    
    scndlvlroot = fullfile(options.roots.results_source, options.condition);
    if ~exist(scndlvlroot, 'dir')
        mkdir(scndlvlroot);
    end
        
    % beta images of 1st level regression for each regressor in each
    % subject serve as input to 2nd level statistics, but here, we only
    % indicate the subject-specific directory of the beta images

    for i_group = 1: numel(options.subjects.group_labels)
        if strcmp(options.subjects.group_labels{i_group}, options.condition)
            
            nSubjects = numel(options.subjects.IDs{i_group});
            imagePaths = cell(nSubjects, 1);
            for sub = 1: nSubjects
                subID = char(options.subjects.IDs{i_group}{sub});
                details = compi_get_subject_details(subID, options);
                imagePaths{sub, 1} = fullfile(details.eeg.erp.source.pathStats);
            end

            % get group covariate information
            if options.eeg.covars
                covars = compi_get_covariates(options, options.subjects.IDs{i_group});
            else
                covars = {};
            end

        end
    end

    % compute the effect of the single-trial regressors on the second level
    compi_2ndlevel_singletrial_sourceERP_groupmean_cov(scndlvlroot, imagePaths, ...
        options, covars)
    
    disp(['Computed 2nd-level statistics for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.erp.type  ' design...']);

end

diary OFF
end



