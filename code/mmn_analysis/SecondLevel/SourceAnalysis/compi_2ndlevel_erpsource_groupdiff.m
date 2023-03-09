function compi_2ndlevel_erpsource_groupdiff(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_ERPSOURCE_GROUPDIFF Computes the second level contrast 
% images for differences in the effects of single-trial (modelbased) 
% regressors for source analysis.
%
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% General analysis options
if nargin < 1
    options = compi_ioio_options;
end

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_erp_source_groupdiff_%s')));

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

VOI    = getfield(load(options.eeg.source.mmnVOI), 'VOI');

try
    % check for previous statistics
    % results file of first regressor
    spmFile = fullfile(options.roots.results_source, 'groupdiff', ...
            options.eeg.erp.regressors{1}, 'SPM.mat');
    load(spmFile);

    disp(['Group difference stats for regressors in ' ...
        options.eeg.erp.type ' design have been computed before.']);

    if options.eeg.source.overwrite
        delete(spmFile);
        disp('Overwriting...');
        error('Continue to group difference stats step');
    else
        disp('Nothing is being done.');
    end
catch
    
    for i_reg =1:numel(options.eeg.erp.regressors)

        for i_source = 1: size(VOI, 1)
            label = VOI{i_source, 1};

            disp(['Computing group difference stats for regressors in the ' ...
                options.eeg.erp.type  ' design...']);
            
             % open a new results folder for each regressor and source
            scndlvlroot = fullfile(options.roots.results_source, 'groupdiff', ...
                options.eeg.erp.regressors{i_reg}, label);
            if ~exist(scndlvlroot, 'dir')
                mkdir(scndlvlroot);
            end
        
            % beta images of 1st level regression for each regressor in each
            % subject and each condition serve as input to 2nd level statistics, 
            % but here, we only indicate the subject-specific directories of the 
            % beta images
            
            % Groups may be different sizes - find max size
            nSubjects = max(cellfun(@length, options.subjects.IDs));
            imagePaths = cell(nSubjects, length(options.subjects.IDs));
    
            for i_group = 1: numel(options.subjects.group_labels)
    
                switch options.eeg.erp.type
                    case {'oddball'}
                        for sub = 1: length(options.subjects.IDs{i_group})
                            subID = char(options.subjects.IDs{i_group}{sub});
                            details = compi_get_subject_details(subID, options);
                            imagePaths{sub, i_group} = fullfile(details.eeg.erp.source.pathStats, ...
                                ['source_' label '_' options.eeg.erp.regressors{i_reg}], ...
                                'smoothed_condition_mmn.nii,1');
                        end
                end
            end
        
            % get covaiates for both groups
            if options.eeg.covars
                covars = compi_get_covariates(options, options.subjects.all);
            else
                covars = {};
            end
            
            % compute the effect of the single-trial regressors on the second level
            % one way ANOVA
            job = compi_oneway_anova(imagePaths, scndlvlroot, covars, options);
            spm_jobman('run',job);
            clear job;
        
        end

        disp(['Computed 2nd-level group difference statistics for regressors ' ...
            'in the ' options.eeg.erp.type ' design.']);
    end
end
cd(options.roots.results);

diary OFF
end