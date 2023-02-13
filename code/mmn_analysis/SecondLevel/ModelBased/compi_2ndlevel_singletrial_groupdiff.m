function compi_2ndlevel_singletrial_groupdiff(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_SINGLETRIAL_GROUPDIFF Computes the second level contrast 
% images for differences in the effects of single-trial (modelbased) 
% regressors.
%
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% General analysis options
if nargin < 1
    options = compi_ioio_options;
end

regressor = options.eeg.stats.regressors; 

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel groupdiff_%s')));

% prepare spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

try
    % check for previous statistics
    % results file of first regressor
    spmFile = fullfile(options.roots.model, 'groupdiff', regressor, ...
           'SPM.mat');
    load(spmFile);

    disp(['Drug difference stats for regressors in ' regressor ...
        ' design have been computed before.']);

    if options.eeg.stats.overwrite
        delete(spmFile);
        disp('Overwriting...');
        error('Continue to drug difference stats step');
    else
        disp('Nothing is being done.');
    end
catch
    
    for i_reg = 1:numel(options.eeg.stats.regressors)

        disp(['Computing group difference stats for regressors in the ' ...
            options.eeg.stats.design  ' design...']);
        
        % make sure we have a results directory
        scndlvlroot = fullfile(options.roots.results_hgf, 'group_diff', options.eeg.stats.regressors{i_reg});
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
%                 case 'epsilon'
%                     for sub = 1: length(options.subjects.IDs{i_group})
%                         subID = char(options.subjects.IDs{i_group}{sub});
%                         details = compi_get_subject_details(subID, options);
%                         imagePaths{sub, i_group} = fullfile(details.eeg.firstLevel.sensor.pathStats, ['beta_000' num2str(i_reg+1) '.nii,1']);
%                     end
                otherwise
                    for sub = 1: length(options.subjects.IDs{i_group})
                        subID = char(options.subjects.IDs{i_group}{sub});
                        details = compi_get_subject_details(subID, options);
                        imagePaths{sub, i_group} = fullfile(details.eeg.firstLevel.sensor.pathStats, options.eeg.stats.regressors{i_reg}, 'beta_0002.nii,1');
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

        
        disp(['Computed 2nd-level group difference statistics for regressors ' ...
            'in the ' options.eeg.stats.design ' design.']);
    end
end
cd(options.roots.results);

diary OFF
end
