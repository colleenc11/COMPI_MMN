function options = compi_mmn_analysis_pipeline(options)
%--------------------------------------------------------------------------
% COMPI_MMN_ANALYSIS_PIPELINE Specify single-subject analysis pipeline.
% IN
%       options       (subject-independent) analysis pipeline options
%                     options = compi_mmn_options()
%--------------------------------------------------------------------------

% cell array with a subset of the following:
% preproc:
%     'correct_eyeblinks'
% stats (erp):
%     'run_regressor_erp'
% stats (sensor):
%     'create_behav_regressors'
%     'ignore_reject_trials'
%     'run_stats_sensor'
% stats (source):
%     'extract_sources'
%     'run_stats_source'
%     'run_erp_source'

options.eeg.pipe.executeStepsPerSubject = {
    'create_behav_regressors'
    'correct_eyeblinks'
    'ignore_reject_trials'
    'run_regressor_erp'
    'run_stats_sensor'
    'extract_sources'
    'run_stats_source'
    'run_erp_source'
    };

end
