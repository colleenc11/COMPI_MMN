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

doCreateRegressors      = ismember('create_behav_regressors', options.eeg.pipe.executeStepsPerSubject);  
doCorrectEyeBlinks      = ismember('correct_eyeblinks', options.eeg.pipe.executeStepsPerSubject);
doIgnoreRejectTrials    = ismember('ignore_reject_trials', options.eeg.pipe.executeStepsPerSubject);
doRegressorERP          = ismember('run_regressor_erp', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSensor        = ismember('run_stats_sensor', options.eeg.pipe.executeStepsPerSubject);
doRunSources            = ismember('extract_sources', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSource        = ismember('run_stats_source', options.eeg.pipe.executeStepsPerSubject);
doRunERPSources         = ismember('run_erp_source', options.eeg.pipe.executeStepsPerSubject);

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

%% ------------------------------------------------------------------------
% ERP BASED ANALYSIS
% -------------------------------------------------------------------------

if doRegressorERP
    fprintf('Running regressor ERP analysis for %s', id);

    % Compute ERPs for model regressors (e.g. epsilons)
    for i_reg = 1:length(options.eeg.stats.design_types)
        design = options.eeg.stats.design_types{i_reg};
        options = compi_get_design_regressors(design, options);

        compi_erp(id, options);
    end

    % Compute ERPs for oddball waveform
    for i_reg = 1:length(options.eeg.erp.design_types)
        design = options.eeg.erp.design_types{i_reg};
        options = compi_get_design_regressors(design, options);

        compi_erp(id, options);
    end
end

% Extract sources based on MIP or fMRI priors for oddball waveform
if doRunERPSources
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Extracting source waveforms for %s', id);
    
    for i_reg = 1:length(options.eeg.erp.design_types)
        design = options.eeg.erp.design_types{i_reg};
        options = compi_get_design_regressors(design, options);

        compi_source_erp(id, options, options.eeg.source.doVisualize)
    end

    options.eeg.type = tmpType;
end

%% ------------------------------------------------------------------------
% MODEL BASED ANALYSIS
% -------------------------------------------------------------------------

% Image conversion and GLM in sensor space
% Based on design matrix, include regressors in one or seperate design
if doRunStatsSensor
    fprintf('Running GLM for %s (Sensor space)', id);

    for i_reg = 1:length(options.eeg.stats.design_types)
        design = options.eeg.stats.design_types{i_reg};
        options = compi_get_design_regressors(design, options);

        compi_stats_adaptable(id, options);
    end
end

% Extract sources based on specified priors
if doRunSources
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Extracting source waveforms for %s', id);
    compi_source(id, options, options.eeg.source.doVisualize)
    options.eeg.type = tmpType;
end

% Image conversion and GLM in source space
if doRunStatsSource
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Running GLM for %s (Source space)', id);

    for i_reg = 1:length(options.eeg.stats.design_types)
        design = options.eeg.stats.design_types{i_reg};
        options = compi_get_design_regressors(design, options);

        compi_stats_adaptable(id, options);
    end

    options.eeg.type = tmpType;
end

close all
