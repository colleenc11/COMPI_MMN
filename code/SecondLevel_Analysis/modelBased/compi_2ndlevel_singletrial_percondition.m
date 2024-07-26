function compi_2ndlevel_singletrial_percondition(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_PERCONDITION Computes the second level 
% contrast images for single-trial (modelbased) regressors in one condition
% 
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_model_%s')));

try
    % check for previous statistics
    switch options.eeg.type
        case 'sensor'
            spmFile = fullfile(options.roots.hgf, options.condition, ...
                options.eeg.stats.regressors{1}, 'SPM.mat');
            resultsRoot = fullfile(options.roots.hgf, options.condition);
            overwrite = options.eeg.stats.overwrite;
        
        case 'source'
            spmFile = fullfile(options.roots.source, options.condition, ...
                options.eeg.stats.regressors{1}, options.eeg.source.exampleLabel, 'SPM.mat');
            resultsRoot = fullfile(options.roots.source, options.condition, ...
                options.eeg.stats.regressors{1});
            overwrite = options.eeg.source.overwrite;
    end

    load(spmFile);
    disp(['2nd level stats for regressors in ' options.eeg.type ' '...
        options.eeg.stats.design ' design in condition '...
        options.condition ' have been computed before.']);

    if overwrite
        delete(resultsRoot);
        disp('Overwriting...');
        error('Continue to 2nd level stats step');
    else
        disp('Nothing is being done.');
    end
catch

    disp(['Computing 2nd level ' options.eeg.type ' stats for regressors in ' ...
        options.eeg.stats.design ' design in condition ' options.condition '...']);
    
    % create output directory
    switch options.eeg.type
        case 'sensor'
            scndlvlroot = fullfile(options.roots.hgf, options.condition, options.eeg.stats.design);
        case 'source'
            scndlvlroot = fullfile(options.roots.source, options.condition, options.eeg.stats.design);
    end

    if ~exist(scndlvlroot, 'dir')
        mkdir(scndlvlroot);
    end

    % beta images of 1st level regression for each regressor in each
    % subject serve as input to 2nd level statistics, but here, we only
    % indicate the subject-specific directory of the images
    for i_group = 1: numel(options.subjects.group_labels)
        if strncmp(options.subjects.group_labels{i_group}, options.condition, 2)
            
            nSubjects = numel(options.subjects.IDs{i_group});
            imagePaths = cell(nSubjects, 1);
            for sub = 1: nSubjects
                subID = char(options.subjects.IDs{i_group}{sub});
                details = compi_get_subject_details(subID, options);
                
                switch options.eeg.type
                    case 'sensor'
                        imagePaths{sub, 1} = fullfile(details.eeg.firstLevel.sensor.pathStats);
                    case 'source'
                        imagePaths{sub, 1} = fullfile(details.eeg.firstLevel.source.pathStats);
                end  
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
    switch options.eeg.type
        case 'sensor'
            compi_2ndlevel_singletrial_groupmean_cov(scndlvlroot, imagePaths, ...
                options, covars);
        case 'source'
                compi_2ndlevel_singletrial_source_groupmean_cov(scndlvlroot, imagePaths, ...
                options, covars);
    end 

    disp(['Computed 2nd-level statistics for regressors for ' ...
        options.condition ' condition in the ' options.eeg.type ' '...
        options.eeg.stats.design  ' design...']);

diary OFF
end



