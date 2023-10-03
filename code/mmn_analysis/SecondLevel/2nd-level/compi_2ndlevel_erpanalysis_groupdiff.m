function compi_2ndlevel_erpanalysis_groupdiff(options)
%COMPI_2NDLEVEL_ERPANALYSIS_DRUGDIFF Computes the second level contrast
%images for ERP effects in one condition in the COMPI study.
%   IN:     options - the struct that holds all analysis options
%   OUT:    --

%% Details
% general analysis options
if nargin < 1
    options = mnCHR_set_analysis_options;
end

%% Main

% record what we're doing
diary(fullfile(options.roots.log, sprintf('secondlevel_erpgroupanalysis_%s')));

factorNames = options.eeg.erp.regressors;

try
    % check for previous group difference erpanalysis
    dirGA = dir(fullfile(options.roots.erp, 'groupdiff', factorNames{i_reg}, 'GA', '*.mat'));
    load(fullfile(dirGA(1).folder, dirGA(1).name));
    disp(['Group differences in ' factorNames{i_reg} ' ERPs have been ' ...
        'computed before.']);
    if options.eeg.erp.overwrite
        clear ga;
        disp('Overwriting...');
        error('Continue to group difference step');
    else
        disp('Nothing is being done.');
    end
catch

    for i_reg = 2:numel(factorNames)


        disp(['Computing group differences in ' factorNames{i_reg} ' ERPs...']);
        
        % make sure we have a results directory
        GAroot = fullfile(options.roots.erp, 'groupdiff', factorNames{i_reg}, 'GA');
        if ~exist(GAroot, 'dir')
            mkdir(GAroot);
        end
        
        % data from both conditions serve as input for drug differences in
        % difference waves
    
        for iCh = 1: numel(options.eeg.erp.channels)
            channel = char(options.eeg.erp.channels{iCh});

            switch factorNames{i_reg}

                case 'oddball_phases'
                    for i_group = 1:length(options.subjects.group_labels)
                        options.condition = char(options.subjects.group_labels{i_group});           
                        group = load(fullfile(options.roots.erp, ...
                            options.condition, factorNames{i_reg}, 'GA', [channel '_ga.mat']));
                        ga.(options.condition) = group.ga.StabMMN;
                    end  
        
                    compi_grandmean_plot(ga, group.ga.electrode, factorNames{i_reg}, options, 'groupdiff_stable');

                    for i_group = 1:length(options.subjects.group_labels)
                        options.condition = char(options.subjects.group_labels{i_group});           
                        group = load(fullfile(options.roots.erp, ...
                            options.condition, factorNames{i_reg}, 'GA', [channel '_ga.mat']));
                        ga.(options.condition) = group.ga.VolMMN;
                    end  
        
                    compi_grandmean_plot(ga, group.ga.electrode, factorNames{i_reg}, options, 'groupdiff_volatile');                    

                otherwise

                    for i_group = 1:length(options.subjects.group_labels)
                        options.condition = char(options.subjects.group_labels{i_group});
            
                        group = load(fullfile(options.roots.erp, ...
                            options.condition, factorNames{i_reg}, 'GA', [channel '_ga.mat']));
            
                        ga.(options.condition) = group.ga.diff;
                    end  
        
                    compi_grandmean_plot(ga, group.ga.electrode, factorNames{i_reg}, options, 'groupdiff');
            
        end

        disp(['Finished computing group differences in ' factorNames{i_reg} ' ERPs.']);

    end
end
close all;
cd(options.roots.results);

diary OFF
end



