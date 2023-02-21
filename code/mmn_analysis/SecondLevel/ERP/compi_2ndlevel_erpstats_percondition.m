function compi_2ndlevel_erpstats_percondition(options)
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
diary(fullfile(options.roots.log, sprintf('secondlevel_erpstats_%s')));

factorNames = options.eeg.erp.regressors;

%%% TO FIX %%%
try
    % check for previous statistics
    spmFile = fullfile(options.roots.erp, options.condition, ...
        factorNames{1}, 'SPM.mat');
    load(spmFile);
    disp(['Group stats for difference waves of ' factorNames{end} ...
        ' ERPs have been computed before.']);
    if options.eeg.erp.overwrite
        delete(fullfile(options.roots.erp, options.condition));
        disp('Overwriting...');
        error('Continue to group stats ERP step');
    else
        disp('Nothing is being done.');
    end
catch

    % loop through regressors
     for i_reg = 1:numel(factorNames)

        disp(['Computing group stats for difference waves of ' ...
            factorNames{i_reg}  ' ERPs...']);
        
        % make sure we have a results directory
        scndlvlroot = fullfile(options.roots.erp, options.condition, ...
            factorNames{i_reg}, 'SPM');
        
        if ~exist(scndlvlroot, 'dir')
            mkdir(scndlvlroot);
        end
        
        % smoothed images of averaged ERP data in one condition in each subject
        % serve as input to 2nd level statistics, but here, we only indicate 
        % the subject-specific directories of the images
    
        for i_group = 1: numel(options.subjects.group_labels)
           
            if strcmp(options.subjects.group_labels{i_group}, options.condition)
                nSubjects = numel(options.subjects.IDs{i_group});
                imagePaths = cell(nSubjects, 1);
                for sub = 1: nSubjects
                    subID = char(options.subjects.IDs{i_group}{sub});
                    details = compi_get_subject_details(subID, options);

                    switch factorNames{i_reg}
                        case {'oddball', 'oddball_phases'}
                            imagePaths{sub, 1} = fullfile(details.eeg.erp.root, ...
                                factorNames{i_reg});
                        otherwise
                            imagePaths{sub, 1} = fullfile(details.eeg.erp.root, ...
                                factorNames{i_reg}, ['sensor_diff_' factorNames{i_reg}]);
                    end
                    
                end
                
                % get group covariate information
                if options.eeg.covars
                    covars = compi_get_covariates(options, options.subjects.IDs{i_group});
                else
                    covars = {};
                end
    
            end
        end
        
        imagePaths = cellstr(imagePaths);
        
        % compute the group difference on the MMN on the second level
        compi_2ndlevel_erpstats_groupmean(scndlvlroot, imagePaths, factorNames{i_reg}, covars, options);


        
        disp(['Computed 2nd-level group statistics for difference ' ...
        'waves of ' factorNames{i_reg} ' ERPs in condition ' options.condition]);
     end
end

diary OFF
end



