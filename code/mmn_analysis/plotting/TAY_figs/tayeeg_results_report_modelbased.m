function tayeeg_results_report_modelbased (options)
%--------------------------------------------------------------------------
% TAYEEG_RESULTS_REPORT_MODELBASED Performs all 2nd level analyses steps for
% modelbased single-trial EEG analysis in the TAY study
%   IN:     --
%   OUT:    --
%--------------------------------------------------------------------------

options.eeg.stats.mode = 'modelbased'; %modelbased, ERP
options.eeg.stats.overwrite = 1;

for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});
    
    tayeeg_report_spm_results(options, options.condition);

    % Note contrast index set to 3 (f-test)
    switch options.eeg.stats.mode
        case 'modelbased'
            for iReg = 1:length(options.eeg.stats.regressors)
                regressor = char(options.eeg.stats.regressors{iReg});
                tayeeg_plot_blobs(regressor, options);
            end
        otherwise
            for iReg = 1:length(options.eeg.erp.regressors)
                regressor = char(options.eeg.erp.regressors{iReg});
                tayeeg_plot_blobs(regressor, options);
            end
    end

end

tayeeg_report_spm_results(options, 'group_diff');

end
