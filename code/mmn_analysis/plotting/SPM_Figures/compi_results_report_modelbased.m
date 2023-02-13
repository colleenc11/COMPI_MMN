function compi_results_report_modelbased (options)
%--------------------------------------------------------------------------
% COMPI_RESULTS_REPORT_MODELBASED Performs all 2nd level analyses steps for
% modelbased single-trial EEG analysis in the COMPI study
%   IN:     --
%   OUT:    --
%--------------------------------------------------------------------------

for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    
    tayeeg_report_spm_results(options, options.condition);

    % Note contrast index set to 3 (f-test)
    for iReg = 1:length(options.eeg.stats.regressors)
        regressor = char(options.eeg.stats.regressors{iReg});
        tayeeg_plot_blobs(regressor, options);
    end

end

tayeeg_report_spm_results(options, 'groupdiff');

end
