function compi_eeg_subject_analysis( id, options )
% -------------------------------------------------------------------------
% COMPI_EEG_SUBJECT_ANALYSIS Performs all analysis steps for one subject 
% of the COMPI study (up until first level modelbased statistics).
% Adapted from dmpad-toolbox: compi_eeg_analyze_subject.
%   IN:     id          subject identifier string, e.g. '0101'
%           options     as set by compi_set_analysis_options();
% -------------------------------------------------------------------------

fprintf('\n===\n\t The following pipeline Steps per subject were selected. Please double-check:\n\n');
disp(options.eeg.pipe.executeStepsPerSubject);
fprintf('\n\n===\n\n');
pause(2);

doCleanupSubject        = ismember('cleanup', options.eeg.pipe.executeStepsPerSubject);
doCreateRegressors      = ismember('create_behav_regressors', options.eeg.pipe.executeStepsPerSubject);  
doCorrectEyeBlinks      = ismember('correct_eyeblinks', options.eeg.pipe.executeStepsPerSubject);
doIgnoreRejectTrials    = ismember('ignore_reject_trials', options.eeg.pipe.executeStepsPerSubject);
doRegressorERP          = ismember('run_regressor_erp', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSensor        = ismember('run_stats_sensor', options.eeg.pipe.executeStepsPerSubject);
doRunSources            = ismember('extract_sources', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSource        = ismember('run_stats_source', options.eeg.pipe.executeStepsPerSubject);
doComputeBetaWave       = ismember('compute_beta_wave', options.eeg.pipe.executeStepsPerSubject);

% Deletes previous preproc/stats files of analysis specified in options
if doCleanupSubject
    compi_cleanup_eeg_subject(id, options)
end

% Creates regressors from behavioral model
if doCreateRegressors
    compi_mmn_model(id, options);
end

% Preparation and Pre-processing
if doCorrectEyeBlinks
    compi_preprocessing_eyeblink_correction(id, options);
end

% Adjust design matrix to reflect rejected trials
if doIgnoreRejectTrials
    fprintf('Adjusting design matrix for %s', id);
    compi_ignore_reject_trials(id, options);
end

% Compute ERPs for model regressors (e.g. epsilons)
if doRegressorERP
    fprintf('Running regressor ERP analysis for %s', id);
    compi_erp(id, options);
end

% Image conversion and GLM in sensor space
% Based on design matrix, include regressors in one or seperate design
if doRunStatsSensor
    fprintf('Running GLM for %s (Sensor space)', id);
    if options.eeg.stats.regDesignSplit
        for i = 1: (numel(options.eeg.stats.regressors)) 
            factor = {options.eeg.stats.regressors{i}};
            compi_stats_adaptable_single_reg(id, factor, options);
        end
    else
        compi_stats_adaptable(id, options);
    end
end

% Extract sources based on fMRI priors
if doRunSources
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Extracting source waveforms for %s', id);
    dmpad_source(id, options, options.eeg.source.doVisualize)
    options.eeg.type = tmpType;
end

% Image conversion and GLM in source space
if doRunStatsSource
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Running GLM for %s (Source space)', id);
    dmpad_stats_adaptable(id, options);
    options.eeg.type = tmpType;
end

% Compute Beta Waveform
if doComputeBetaWave
    fprintf('Running Beta Wave computation for %s', id);
    dmpad_contrast(id, options);
end

close all
