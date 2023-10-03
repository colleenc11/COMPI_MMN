function compi_results_report_modelbased (options)
%--------------------------------------------------------------------------
% COMPI_RESULTS_REPORT_MODELBASED Create figures for modelbased 
% single-trial EEG analysis in the TAY study
%   IN:     options   - the struct that contains all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% General stats

options.eeg.stats.pValueMode    = 'peakFWE'; %clusterFWE, peakFWE
options.eeg.fig.contrastIdx     = 3; %F-contrast

%% Plot modelbased results
options.eeg.stats.mode          = 'modelbased';   

for i_reg = 1:length(options.eeg.stats.regressors)
    options.eeg.stats.currRegressor = {options.eeg.stats.regressors{i_reg}};

    for i_group = 1:length(options.subjects.group_labels)
        options.condition = char(options.subjects.group_labels{i_group});
        compi_report_spm_results(options, options.condition);
        compi_plot_blobs(options);
        compi_extract_first_last_sig_voxel(options, options.condition);
    end
 
end

options.condition = 'groupdiff';
compi_report_spm_results(options, 'groupdiff');

%% Extract first and last significant peak voxel

options.eeg.stats.pValueMode    = 'peakFWE'; %clusterFWE, peakFWE
options.eeg.fig.contrastIdx     = 3; %F-contrast
options.eeg.stats.mode          = 'modelbased'; 

for i_reg = 1:length(options.eeg.stats.regressors)
    options.eeg.stats.currRegressor = {options.eeg.stats.regressors{i_reg}};

    for i_group = 1:length(options.subjects.group_labels)
        options.condition = char(options.subjects.group_labels{i_group});
        compi_extract_first_last_sig_voxel(options, options.condition);
    end
 
end

%% Plot erpbased results

options.eeg.stats.mode          = 'erpbased';  
options.eeg.stats.currRegressor   = {'oddball_volatile'}; %oddball_phases
options.eeg.fig.contrastIdx     = 6;
options.eeg.stats.pValueMode    = 'peakFWE';

for i_group = 1:length(options.subjects.group_labels)
    % options.condition = char(options.subjects.group_labels{i_group});
    compi_report_spm_results(options, options.condition);
    compi_plot_blobs(options);
    compi_extract_first_last_sig_voxel(options, options.condition);
end

%% Extract first and last significant peak voxel

options.eeg.stats.pValueMode    = 'peakFWE'; %clusterFWE, peakFWE
options.eeg.fig.contrastIdx     = 1; %F-contrast
options.eeg.stats.mode          = 'erpbased'; 

options.eeg.stats.currRegressor   = {'oddball_phases'};

for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    compi_extract_first_last_sig_voxel(options, options.condition);
end
 

end