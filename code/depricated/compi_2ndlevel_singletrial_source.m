function compi_2ndlevel_singletrial_source(options)
%--------------------------------------------------------------------------
% Computes the second level contrast images for single-trial (modelbased)
% regressors in one condition for source analysis. 
% 
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_source_model_%s')));

try
    % check for previous statistics


    
    spmFile = fullfile(options.roots.results_source, options.condition, ...
        options.eeg.stats.regressors{1}, options.eeg.source.exampleLabel, 'SPM.mat');
    load(spmFile);
    disp(['2nd level stats for regressors in ' options.eeg.stats.design ...
        ' design in condition ' options.condition ...
        ' have been computed before.']);
    if options.eeg.source.overwrite
        delete(fullfile(options.roots.results_source, options.condition, ...
            options.eeg.stats.regressors{1}, options.eeg.source.exampleLabel, 'SPM.mat'));
        disp('Overwriting...');
        error('Continue to 2nd level stats step');
    else
        disp('Nothing is being done.');
    end
catch

    disp(['Computing 2nd level source stats for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.stats.design  ' design...']);
    
    scndlvlroot = fullfile(options.roots.results_source, options.condition);
    if ~exist(scndlvlroot, 'dir')
        mkdir(scndlvlroot);
    end

    % beta images of 1st level regression for each regressor in each
    % subject serve as input to 2nd level statistics, but here, we only
    % indicate the subject-specific directory of the beta images

    for i_group = 1: numel(options.subjects.group_labels)
        if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
            
            nSubjects = numel(options.subjects.IDs{i_group});
            imagePaths = cell(nSubjects, 1);
            for sub = 1: nSubjects
                subID = char(options.subjects.IDs{i_group}{sub});
                details = compi_get_subject_details(subID, options);
                imagePaths{sub, 1} = fullfile(details.eeg.firstLevel.source.pathStats);
            end

            % get group covariate information
            if options.eeg.covar.include
                covars = compi_get_covariates(options.eeg.covar.covariate_names, ...
                    options.subjects.IDs{i_group}, options);
            else
                covars = {};
            end

        end
    end

    % compute the effect of the single-trial regressors on the second level
    compi_2ndlevel_singletrial_source_groupmean_cov(scndlvlroot, imagePaths, ...
        options, covars)
    
    disp(['Computed 2nd-level statistics for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.stats.design  ' design...']);

diary OFF
end
end