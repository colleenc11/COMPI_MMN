function compi_2ndlevel_erpanalysis_percondition(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_ERPANALYSIS_PERCONDITION Computes the grandaverages of 
% ERPs in one condition.
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------


%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_erp_%s')));

% get new condition names
factorNames = options.eeg.stats.regressors;

try
    % check for previous erpanalysis
    dirGA = dir(fullfile(options.roots.erp, options.condition, factorNames{end}, 'GA', '*.mat'));
    load(fullfile(dirGA(1).folder, dirGA(1).name));
    disp(['Grand averages of ' factorNames{end} ' ERPs have been ' ...
        'computed before.']);
    if options.eeg.erp.overwrite
        clear ga;
        disp('Overwriting...');
        error('Continue to grand average step');
    else
        disp('Nothing is being done.');
    end
catch

    for i_reg = 1:numel(factorNames)

        disp(['Computing grand averages of ' factorNames{i_reg}  ' ERPs...']);
        
        % make sure we have a results directory
        GAroot = fullfile(options.roots.erp, options.condition, factorNames{i_reg}, 'GA');
        if ~exist(GAroot, 'dir')
            mkdir(GAroot);
        end
        
        % averaged ERP data in one condition in each subject
        % serve as input to 2nd level grand averages 
        for i_group = 1: numel(options.subjects.group_labels)
            if strcmp(options.subjects.group_labels{i_group}, options.condition)
                
                nSubjects = numel(options.subjects.IDs{i_group});
                erpfiles = cell(nSubjects, 1);
                for sub = 1: nSubjects
                    subID = char(options.subjects.IDs{i_group}{sub});
                    details = compi_get_subject_details(subID, options);
                    erpfiles{sub, 1} = fullfile(details.eeg.erp.root, factorNames{i_reg}, ['diff_' factorNames{i_reg} '.mat']);
                end
    
            end
        end
        
        % compute the grand averages and variance estimates for selected electrodes
        % and plot it right away
        % for iCh = 1: numel(options.eeg.erp.channels)
        %     channel = char(options.eeg.erp.channels{iCh});
        %     ga = compi_grandmean_with_error(erpfiles, channel, factorNames{i_reg}, 1);
        %     save(fullfile(GAroot, [channel, '_ga']), 'ga');
        % 
        %     compi_grandmean_plot(ga, channel, factorNames{i_reg}, options);
        % end
        % close all;
        
        % compute the grand averages for all electrodes using SPM
        outFile = fullfile(GAroot, ['GA_' factorNames{i_reg}]);
        D = tnueeg_grandmean_spm(erpfiles, outFile);
        copy(D, outFile);
        disp(['Computed grand averages of ' factorNames{i_reg} ' ERPs '...
            'in condition ' options.condition]);
    end
end
close all;
cd(options.roots.results);

diary OFF
end