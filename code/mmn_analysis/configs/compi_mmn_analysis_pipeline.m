function options = compi_mmn_analysis_pipeline(options)
%--------------------------------------------------------------------------
% COMPI_MMN_ANALYSIS_PIPELINE Specify single-subject analysis pipeline.
% IN
%       options       (subject-independent) analysis pipeline options
%                     options = compi_set_analysis_options
%--------------------------------------------------------------------------

% cell array with a subset of the following:
% general (for all subgroups below)
%     'cleanup'
% preproc:
%     'correct_eyeblinks'
% stats (erp):
%     'run_regressor_erp'
% stats (sensor):
%     'create_behav_regressors'
%     'ignore_reject_trials'
%     'run_stats_sensor'
%     'compute_beta_wave'
% stats (source):
%     'extract_sources'
%     'run_stats_source'
%
%  NOTE: 'cleanup' only cleans up files (deletes them) that will be
%  recreated by the other specified pipeline steps in the array
%  See also dmpad_analyze_subject

options.eeg.pipe.executeStepsPerSubject = {
    'cleanup'
    'correct_eyeblinks'
    'create_behav_regressors'
    'ignore_reject_trials'
    'run_regressor_erp'
    'run_stats_sensor'
    'extract_sources'
    'run_stats_source'
    };

end
