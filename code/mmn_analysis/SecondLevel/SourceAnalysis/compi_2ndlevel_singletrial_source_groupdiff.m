function compi_2ndlevel_singletrial_source_groupdiff(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_SOURCE_GROUPDIFF Computes the second level contrast 
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
diary(fullfile(options.roots.log, sprintf('secondlevel_source_groupdiff_%s')));

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

VOI    = getfield(load(options.eeg.source.mmnVOI), 'VOI');

try
    % check for previous statistics
    % results file of first regressor
    spmFile = fullfile(options.roots.results_source, 'groupdiff', ...
            options.eeg.stats.regressors{1}, 'SPM.mat');
    load(spmFile);

    disp(['Group difference stats for regressors in ' ...
        options.eeg.stats.design ' design have been computed before.']);

    if options.eeg.source.overwrite
        delete(spmFile);
        disp('Overwriting...');
        error('Continue to group difference stats step');
    else
        disp('Nothing is being done.');
    end
catch
    
    for i_reg = 1:numel(options.eeg.stats.regressors)

        for i_source = 5: size(VOI, 1)
            label = VOI{i_source, 1};

            disp(['Computing group difference stats for regressors in the ' ...
                options.eeg.stats.design  ' design...']);
            
             % open a new results folder for each regressor and source
            scndlvlroot = fullfile(options.roots.results_source, 'group_diff', ...
                options.eeg.stats.regressors{i_reg}, label);
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
    
                switch options.eeg.stats.design
                    case {'lowPE', 'highPE'}
                        for sub = 1: length(options.subjects.IDs{i_group})
                            subID = char(options.subjects.IDs{i_group}{sub});
                            details = compi_get_subject_details(subID, options);
                            imagePaths{sub, i_group} = fullfile(details.eeg.firstLevel.source.pathStats, ...
                                ['beta_000' num2str(i_reg+1) '.nii,1']);
                        end
                    otherwise
                        for sub = 1: length(options.subjects.IDs{i_group})
                            subID = char(options.subjects.IDs{i_group}{sub});
                            details = compi_get_subject_details(subID, options);
                            imagePaths{sub, i_group} = fullfile(details.eeg.firstLevel.source.pathStats, ...
                                options.eeg.stats.regressors{i_reg}, label, 'beta_0002.nii,1');
                        end
                end
            end
        
            % get covaiates for both groups
            if options.eeg.stats.covars
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
            'in the ' options.eeg.stats.design ' design.']);
    end
end
cd(options.roots.results);

diary OFF
end