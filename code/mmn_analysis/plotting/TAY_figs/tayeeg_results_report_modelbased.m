function tayeeg_results_report_modelbased (options)
%--------------------------------------------------------------------------
% TAYEEG_RESULTS_REPORT_MODELBASED Create figures for modelbased 
% single-trial EEG analysis in the TAY study
%   IN:     options   - the struct that contains all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% General stats

options.stats.pValueMode    = 'clusterFWE'; %clusterFWE, peakFWE
options.fig.contrastIdx     = 3; %F-contrast

%% Plot modelbased results
options.stats.mode          = 'modelbased';   

for i_reg = 1:length(options.eeg.stats.regressors)
    options.eeg.stats.currRegressor = {options.eeg.stats.regressors{i_reg}};

    for i_group = 1:length(options.subjects.group_labels)
        options.condition = char(options.subjects.group_labels{i_group});
        tayeeg_report_spm_results(options, options.condition);
        tayeeg_plot_blobs(options);
    end
 
end

tayeeg_report_spm_results(options, 'groupdiff');

%% Plot erpbased results
options.stats.mode          = 'erpbased';  
options.eeg.stats.currRegressor   = {'oddball'};

for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    tayeeg_report_spm_results(options, options.condition);
    tayeeg_plot_blobs(options);
end


end
