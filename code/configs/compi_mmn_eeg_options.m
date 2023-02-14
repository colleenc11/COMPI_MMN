function [options] = compi_mmn_eeg_options(options, preprocStrategyValueArray)


%% EEG Single-subject analysis pipeline
% cell array with a subset of the following:
% general (for all subgroups below)
%     'cleanup'
% preproc:
%     'correct_eyeblinks'
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
%     'cleanup'
%     'correct_eyeblinks'
%     'create_behav_regressors'
%     'ignore_reject_trials'
%     'run_regressor_erp'
    'run_stats_sensor'
    %'compute_beta_wave'
    };

% Other options not executed yet are:
%     'extract_sources'
%     'run_stats_source'


%% EEG Analysis Options IOIO
options.eeg.batchesroot = fullfile(options.roots.code, 'eeg','dmpad-toolbox',...
    'EEG', 'CustomSPMPreprocAnalysis', 'batches');
options.eeg.montage     = fullfile(options.roots.config, 'COMPI_montage.mat');
options.eeg.eegtemplate = fullfile(options.roots.config, 'COMPI_64ch.sfp');
options.eeg.eegchannels = fullfile(options.roots.config, 'compi_eeg_channels.mat');
options.eeg.part        = 'FEP';
options.eeg.type        = 'sensor';

options.eeg.covar.file = fullfile(options.roots.data, 'clinical', 'input_mask_LM.xlsx');
options.eeg.covar.all = {};

% Preprocessing-----------------------------------------------------------%
% set options for most common preproc parameters to form a preproc strategy
% (pipeline), separated in its own preproc directory
preprocessing = compi_set_preprocessing_strategy(options.roots.results, preprocStrategyValueArray);
disp(preprocessing.selectedStrategy.valueArray);

options.eeg.preprocStrategyValueArray       = preprocStrategyValueArray;
options.eeg.preproc.eyeCorrection           = true;
options.eeg.preproc.eyeCorrMethod           = ...
    preprocessing.eyeCorrectionMethod{preprocessing.selectedStrategy.valueArray(3)};% other option; 'SSP'

options.eeg.preproc.downsample              = preprocessing.downsample{preprocessing.selectedStrategy.valueArray(5)};
options.eeg.preproc.downsamplefreq          = 256;
options.eeg.preproc.lowpassfreq             = str2num(preprocessing.lowpass{preprocessing.selectedStrategy.valueArray(6)});
options.eeg.preproc.highpassfreq            = str2num(preprocessing.highpass{preprocessing.selectedStrategy.valueArray(10)});
% options.eeg.preproc.highpassfreq            = 0.5; %0.1 (Weber), 0.5(COMPI)
options.eeg.preproc.baselinecorrection      = str2num(preprocessing.baseline{preprocessing.selectedStrategy.valueArray(7)});
options.eeg.preproc.smoothing               = preprocessing.smoothing{preprocessing.selectedStrategy.valueArray(8)};

options.eeg.preproc.mrifile                 = 'template';

%the following parameters are overwritten for some subjects in details
options.eeg.preproc.eyeDetectionThreshold   = preprocessing.eyeDetectionThreshold{preprocessing.selectedStrategy.valueArray(2)};% other option: default (i.e., set to 3 for all subjects)
options.eeg.preproc.eyeDetectionThresholdDefault = 3; % for SD thresholding: in standard deviations, for amp in uV
options.eeg.preproc.nComponentsforRejection = str2num(preprocessing.eyeCorrectionComponentsNumber{preprocessing.selectedStrategy.valueArray(4)});

% options needed for EB rejection
options.eeg.preproc.eyeblinkmode        = 'eventbased'; % uses EEG triggers for trial onsets
options.eeg.preproc.eyeblinkwin         = [-500 500]; % in s around blink events
options.eeg.preproc.eyeblinktrialoffset = 0.1; % in s: EBs won't hurt <100ms after tone onset
options.eeg.preproc.eyeblinkEOGchannel  = 'VEOG'; % EOG channel (name/idx) to plot
options.eeg.preproc.eyebadchanthresh    = 0.2; % prop of bad trials due to EBs
options.eeg.preproc.badtrialthresh          = ...
    str2num(preprocessing.badTrialsThreshold{preprocessing.selectedStrategy.valueArray(1)}); % in microVolt

options.eeg.preproc.grouproot               = preprocessing.root;

% Montage
options.eeg.preproc.montage.examplefile     = fullfile(options.roots.config, 'spmeeg_compi_VL_01.mat');
options.eeg.preproc.montage.veog            = [71 72];
options.eeg.preproc.montage.heog            = [69 70];
options.eeg.preproc.digitization            = ...
    preprocessing.digitization{preprocessing.selectedStrategy.valueArray(9)};


% Additional Bad Trial/Bad Channel definition options
% Used for PSSP
options.eeg.preproc.artifact.badtrialthresh = 500;
% options.eeg.preproc.artifact.lowPassFilter  = 10;
options.eeg.preproc.artifact.badchanthresh  = 0.2;

options.eeg.preproc.rereferencing       = 'avref'; % avref, noref
options.eeg.preproc.trialdef            = 'tone'; % tone, oddball
% options.eeg.preproc.trlshift            = 25; % set to 125 for pilots in anta?
options.eeg.preproc.epochwin            = [-100 450];

options.eeg.preproc.checkChannel = {'TP7', 'FT9', 'Cz'};

% steps you can turn on/off for saving/rewrite purposes
options.eeg.preproc.overwrite               = 1; % whether to overwrite any prev. prepr
options.eeg.preproc.keep                    = 1; % whether to keep intermediate data
options.eeg.preproc.keepotherchannels       = 1; % for montage

%% -- erp ------------------------------------------------------------------%

options.eeg.erp.type        = 'oddball'; % delta, epsilon, roving, oddball_phases,
options.eeg.erp.covars        = 0; % include covariates? 1 = yes, 0 = no
% phases_roving, split_phases
switch options.eeg.erp.type
    case 'oddball' 
        options.eeg.erp.regressors = {'oddball'};
    case 'oddball_phases' 
        options.eeg.erp.regressors = {'oddball_phases'};
    case 'epsilon'
        options.eeg.erp.regressors = {'epsilon2', 'epsilon3'};
    case 'delta'
        options.eeg.erp.regressors = {'delta1', 'delta2'};
    case 'precision'
        options.eeg.erp.regressors = {'pi1', 'pi2', 'pi3'};
end

options.eeg.erp.electrode   = 'Fz';
options.eeg.erp.averaging   = 'r'; % s (standard), r (robust)
switch options.eeg.erp.averaging
    case 'r'
        options.eeg.erp.addfilter = 'f';
    case 's'
        options.eeg.erp.addfilter = '';
end

options.eeg.erp.contrastWeighting   = 1;
options.eeg.erp.contrastPrefix      = 'diff_';
options.eeg.erp.contrastName        = 'mmn';
options.eeg.erp.percentPe           = 20;

options.eeg.erp.channels   = {'C3', 'C1', 'Cz', 'FC1', 'FC2', 'FC3', 'FC4', 'FC6', 'FCz', ...
                        'F1', 'F2', 'Fz', 'Fpz', 'P5', 'P7', ...
                        'P8', 'P9', 'P10', 'PO7', 'PO8','POz', 'Pz', 'O2', 'O1', 'TP7'};

%-- conversion2images ----------------------------------------------------%
options.eeg.conversion.mode             = 'modelbased'; %'ERPs', 'modelbased',
%'mERPs', 'diffWaves'
options.eeg.conversion.space            = 'sensor';
options.eeg.conversion.convPrefix       = 'sensor'; % whole, early, late, ERP
options.eeg.conversion.convTimeWindow   = [100 450];
options.eeg.conversion.smooKernel       = [16 16 0];

options.eeg.conversion.overwrite        = 1;

%-- stats ----------------------------------------------------------------%
options.eeg.stats.mode          = 'modelbased';         % 'modelbased', 'ERP'
options.eeg.stats.covars        = 0;                    % include covariates? 1 = yes, 0 = no
options.eeg.stats.firstLevelAnalysisWindow = [100 450];
options.eeg.stats.priors        = 'volTrace';           % omega35, default, mypriors,
% kappa2, peIncrease, volTrace
options.eeg.stats.design        = 'lowPE';            % delta, epsilon, precision
options.eeg.stats.designPruned  = true;                 % if true, rejected trials are removed from conversion and design matrix

switch options.eeg.stats.design
    case 'epsilon'
        options.eeg.stats.regressors = {'epsilon2', 'epsilon3'};
        options.eeg.stats.regDesignSplit = 1;
    case 'delta'
        options.eeg.stats.regressors = {'delta1', 'delta2'};
        options.eeg.stats.regDesignSplit = 1;
    case 'precision'
        options.eeg.stats.regressors = {'pi1', 'pi2', 'pi3'};
        options.eeg.stats.regDesignSplit = 1;
    case 'lowPE'
        options.eeg.stats.regressors = {'delta1', 'psi2'};
        options.eeg.stats.regDesignSplit = 0;
    case 'highPE'
        options.eeg.stats.regressors = {'delta2', 'psi3'};
        options.eeg.stats.regDesignSplit = 0;
end

options.eeg.stats.pValueMode    = 'clusterFWE';
options.eeg.stats.exampleID     = '0001';
options.eeg.stats.overwrite     = 1;