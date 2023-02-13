function compi_2ndlevel_singletrial_percondition(options)
%--------------------------------------------------------------------------
% Computes the second level contrast images for single-trial (modelbased)
% regressors in one condition
% 
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_model_%s')));

factorNames = options.eeg.stats.regressors;

try
    % check for previous statistics
    spmFile = fullfile(options.roots.model, options.condition, ...
        factorNames{1}, 'SPM.mat');
    load(spmFile);
    disp(['2nd level stats for regressors in ' options.eeg.stats.design ...
        ' design in condition ' options.condition ...
        ' have been computed before.']);
    if options.eeg.stats.overwrite
        delete(fullfile(options.roots.results_hgf, options.condition));
        disp('Overwriting...');
        error('Continue to 2nd level stats step');
    else
        disp('Nothing is being done.');
    end
catch

    disp(['Computing 2nd level stats for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.stats.design  ' design...']);
    
    scndlvlroot = fullfile(options.roots.results_hgf, options.condition);
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
                imagePaths{sub, 1} = fullfile(details.eeg.firstLevel.sensor.pathStats);
            end

            % get group covariate information
            if options.eeg.stats.covars
                covars = compi_get_covariates(options, options.subjects.IDs{i_group});
            else
                covars = {};
            end

        end
    end

    % compute the effect of the single-trial regressors on the second level
    compi_2ndlevel_singletrial_groupmean_cov(scndlvlroot, imagePaths, ...
        factorNames, options, covars)
    
    disp(['Computed 2nd-level statistics for regressors for ' ...
        options.condition ' condition in the ' ...
        options.eeg.stats.design  ' design...']);

diary OFF
end



