function [options] = compi_ioio_eeg_options(options, preprocStrategyValueArray, firstLevelDesignName)


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


%% Group Level analysis pipeline options
% steps that are performed for all subjects at once, include any of the
% following in a cell array:
%
%       'run_stats_2ndlevel_sensor'
%       'run_stats_2ndlevel_source'
%       'create_figure_eeg_temporal_hierarchy_blobs'
%       'create_figure_eeg_temporal_hierarchy_timeseries'
%
options.eeg.pipe.executeStepsGroup = {''
    }; % second level analysis not executed at the moment



%% EEG Analysis Options IOIO
options.eeg.batchesroot = fullfile(options.roots.code, 'eeg','dmpad-toolbox',...
    'EEG', 'CustomSPMPreprocAnalysis', 'batches');
options.eeg.montage     = fullfile(options.roots.config, 'COMPI_montage.mat');
options.eeg.eegtemplate = fullfile(options.roots.config, 'COMPI_64ch.sfp');
options.eeg.eegchannels = fullfile(options.roots.config, 'compi_eeg_channels.mat');
options.eeg.part        = 'FEP';
options.eeg.type        = 'sensor';

options.eeg.covar.file = fullfile(options.roots.data, 'clinical', 'input_mask_LM.xlsx');
options.eeg.covar.all = {'SocDem_age'};

% Preprocessing-----------------------------------------------------------%
% set options for most common preproc parameters to form a preproc strategy
% (pipeline), separated in its own preproc directory
preprocessing = compi_set_preprocessing_strategy(options.roots.results, preprocStrategyValueArray);
disp(preprocessing.selectedStrategy.valueArray);

options.eeg.preprocStrategyValueArray       = preprocStrategyValueArray;
options.eeg.preproc.eyeCorrection           = true;
options.eeg.preproc.eyeCorrMethod           = ...
    preprocessing.eyeCorrectionMethod{preprocessing.selectedStrategy.valueArray(3)};% other option; 'SSP'
options.eeg.preproc.eyeDetectionThreshold   = ...
    preprocessing.eyeDetectionThreshold{preprocessing.selectedStrategy.valueArray(2)};% other option: default (i.e., set to 3 for all subjects)
options.eeg.preproc.eyeDetectionThresholdDefault = 3;
options.eeg.preproc.downsample              = preprocessing.downsample{preprocessing.selectedStrategy.valueArray(5)};
options.eeg.preproc.downsamplefreq          = 256;
options.eeg.preproc.overwrite               = 1; % whether to overwrite any prev. prepr
options.eeg.preproc.mrifile                 = 'template';
options.eeg.preproc.keep                    = 1; % whether to keep intermediate data
options.eeg.preproc.lowpassfreq             = str2num(preprocessing.lowpass{preprocessing.selectedStrategy.valueArray(6)});
options.eeg.preproc.highpassfreq            = 0.5;
options.eeg.preproc.epochwin                = [-100 650]; % choose the range in which artefacts would be an issue for the statistics
options.eeg.preproc.eyeblinkwin             = [-500 500];
options.eeg.preproc.eyeblinkchannels        = {'VEOG'};
options.eeg.preproc.baselinecorrection      = str2num(preprocessing.baseline{preprocessing.selectedStrategy.valueArray(7)});
options.eeg.preproc.smoothing               = preprocessing.smoothing{preprocessing.selectedStrategy.valueArray(8)};
% options needed for EB rejection
options.eeg.preproc.eyeblinkmode            = 'eventbased'; % uses EEG triggers for trial onsets
options.eeg.preproc.eyeblinkwindow          = 1; % in s around blink events
options.eeg.preproc.eyeblinktrialoffset     = 0.05; % in s: window to discard at beg. of trial
options.eeg.preproc.eyeblinkEOGchannel      = 'VEOG'; % EOG channel (name/idx) to plot

% the following 2 parameters are overwritten for some subjects in details
options.eeg.preproc.nComponentsforRejection = ...
    str2num(preprocessing.eyeCorrectionComponentsNumber{preprocessing.selectedStrategy.valueArray(4)});
options.eeg.preproc.artifact.badtrialthresh = 500;
options.eeg.preproc.artifact.lowPassFilter  = 10;

options.eeg.preproc.badchanthresh           = 0.2; % proportion of bad trials
options.eeg.preproc.badtrialthresh          = ...
    str2num(preprocessing.badTrialsThreshold{preprocessing.selectedStrategy.valueArray(1)}); % in microVolt
options.eeg.preproc.artifact.badchanthresh  = 0.2;
options.eeg.preproc.grouproot               = preprocessing.root;
options.eeg.preproc.montage.examplefile     = fullfile(options.roots.config, 'spmeeg_compi_VL_01.mat');
options.eeg.preproc.montage.veog            = [71 72];
options.eeg.preproc.montage.heog            = [69 70];
options.eeg.preproc.keepotherchannels       = 1;
options.eeg.preproc.digitization            = ...
    preprocessing.digitization{preprocessing.selectedStrategy.valueArray(9)};

% First level analysis
options.eeg.preproc.trialdef                = 'ioio_outcome';
options.eeg.firstLevelAnalysis.type         = 'Outcome';

switch options.eeg.firstLevelAnalysis.type
    case 'Outcome'
        options.eeg.firstLevelAnalysis.eventType = [12];
        options.eeg.firstLevelAnalysis.eventCodeRange = [17 40];
    case 'Prediction'
        options.eeg.firstLevelAnalysis.eventType = [4];
        options.eeg.firstLevelAnalysis.eventCodeRange = [9 14];
end

%% Quality check ----------------------------------------------------------%
options.eeg.preproc.checkChannel = {'TP7', 'FT9', 'Cz'};

%% 1st Level GLM EEG IOIO ----------------------------------------------------------%
% possible 1st level designs:
options.eeg.firstLevelDesignNameArray = {'PEs', 'PEsPhase', 'Default', 'Full', 'ValencePE', 'HGF',...
    'Uncertainty','All','TransformedOutcome','TransformedPrediction'};
options.eeg.firstLevelDesignName = firstLevelDesignName; % 'ValencePE'; % 'Full'; 'Default';
switch lower(options.eeg.firstLevelDesignName)
    case 'pes'
        options.eeg.firstLevelDesignInit   = 'PEDesignMatrix';
    case 'pesphase'
        options.eeg.firstLevelDesignInit   = 'PEPhaseDesignMatrix';
    case 'default'
        options.eeg.firstLevelDesignInit   = 'Control';
    case 'full'
        options.eeg.firstLevelDesignInit   = ['FullDesignMatrix']; % Initial Design matrix: 'FullDesignMatrix',
    case 'valencepe'
        options.eeg.firstLevelDesignInit   = ['DesignMatrix_' options.eeg.firstLevelDesignName]; % Initial Design matrix: 'FullDesignMatrix', 'DesignMatrix', 'DesignMatrix_ValencePE'
    case 'hgf'
        options.eeg.firstLevelDesignInit   = ['HGF'];
    case 'uncertainty'
        options.eeg.firstLevelDesignInit   = ['FullDesignMatrixUncertainty'];
    case 'all'
        options.eeg.firstLevelDesignInit   = ['PredictionwithBeliefUpdating'];
    case 'transformedoutcome'
        options.eeg.firstLevelDesignInit   = ['Transformed_FullDesignMatrix'];
    case 'transformedprediction'
        options.eeg.firstLevelDesignInit   = ['Transformed_DesignMatrixPrediction'];
end
options.eeg.firstLevelDesignPruned       = [options.eeg.firstLevelDesignInit, '_Pruned']; % rejected trial removed from conversio
options.eeg.firstLevelDesignUsePruned    = true; % if true, rejected trials are removed from conversion and design matrix
options.eeg.firstLevelAnalysisWindow     = [0 550];

if options.eeg.firstLevelDesignUsePruned
    options.eeg.firstLevelDesign   = options.eeg.firstLevelDesignPruned;
else
    options.eeg.firstLevelDesign   = options.eeg.firstLevelDesignInit;
end

%% EEG Image Conversion------------------------------------------------------------%
options.eeg.conversion.smooKernel       = [16 16 0];
options.eeg.conversion.convPrefix       = 'sensor';
options.eeg.conversion.convTimeWindow   = options.eeg.firstLevelAnalysisWindow;
options.eeg.conversion.space            = 'sensor';
options.eeg.conversion.overwrite        = 1;
options.eeg.conversion.convTime         = 'whole';

switch options.eeg.conversion.convTime
    case 'early'
        options.eeg.conversion.convTimeWindow = [100 250];
    case 'late'
        options.eeg.conversion.convTimeWindow = [250 400];
    case 'whole'
        options.eeg.conversion.convTimeWindow = [0 550];
    case 'ERP'
        options.eeg.conversion.convTimeWindow = [-100 400];
end

%% ERP Analysis------------------------------------------------------------%
options.eeg.erp.type = 'PEs'; % 2bins, phase, PEs, all

switch options.eeg.erp.type
    case 'phase'
        options.eeg.erp.regressors = {'phase'}; %{'stable1', 'volatile', 'stable2'};
    case '2bins'
        options.eeg.erp.regressors = {'2bins'}; %{'stable', 'volatile'};
    case 'PEs'
        options.eeg.erp.regressors = {'CuePE', 'OutcomePE'};
    case 'all'
        options.eeg.erp.regressors = {'CuePE', 'SignedDelta1', 'OutcomePE', ...
            'Precision2', 'Delta2', 'Precision3', 'Delta3'};
end

options.eeg.erp.percentPe = 20;

options.eeg.erp.averaging        = 'r'; % s (standard), r (robust)
switch options.eeg.erp.averaging
    case 'r'
        options.eeg.erp.addfilter = 'f';
    case 's'
        options.eeg.erp.addfilter = '';
end


options.eeg.erp.channels          = {'C3', 'C1', 'Cz', 'CP2', 'CPz'...
    'AF4', 'AF3', 'FC5', 'FC6', ...
    'FC1', 'FC2', 'FCz', ...
    'F1', 'F2', 'Fz', 'F3', 'F6', ...
    'P7', 'P8', 'CP6', 'CP5', 'Pz'...
    'TP7', 'TP8', 'Oz', 'POz'};
% options.eeg.secondlvl_erpfold = fullfile(options.eeg.preproc.grouproot, 'erp');
% options.eeg.secondlvl_source_erpfold = fullfile(options.eeg.preproc.grouproot,'source_erp');

options.eeg.erp.electrode = 'Cz';

options.eeg.erp.contrastWeighting   = 1;
options.eeg.erp.contrastPrefix      = 'diff_';

%% EEG Source Analysis--------------------------------------------------------%
options.eeg.source.VOI            = fullfile(options.roots.config, 'compi_voi_msp.mat');
options.eeg.source.radius         = 16;
options.eeg.source.msp            = true;
options.eeg.source.priors         = fullfile(options.roots.config, 'priors.mat');
options.eeg.source.priorsmask     = {''};
options.eeg.source.doVisualize    = false;
options.eeg.source.secondlevelDir = ...
    fullfile(options.eeg.preproc.grouproot, [options.eeg.part '_Source_' options.eeg.firstLevelDesign]);
options.eeg.source.type           = 'source';

%% EEG Second level Analysis-----------------------------------------------------------------%
options.eeg.secondlevelDir.classical = ...
    fullfile(options.eeg.preproc.grouproot, [options.eeg.part '_' options.eeg.firstLevelDesign]);
options.eeg.secondlevel_eyeblinksDir = [options.eeg.secondlevelDir.classical '_Corrected_Eyeblinks'];
options.eeg.secondlevelDesign        =  options.eeg.firstLevelDesign;
options.eeg.secondlevelAnalysisTemplate.classical ...
    = fullfile(options.eeg.batchesroot, 'secondLevel_cov_template.m');
options.eeg.secondlevelAnalysisTemplate.bayesian ...
    = fullfile(options.eeg.batchesroot, 'secondLevel_cov_template_bayesian.m');
options.eeg.secondlevelAnalysisTemplate.nonparametric ...
    = fullfile(options.eeg.batchesroot, 'secondLevel_cov_template_nonparametric.m');

options.eeg.secondlevelAnalysisTemplate.anova    ...
    = fullfile(options.eeg.batchesroot, 'anova_test_job.m');
options.eeg.secondlevelAnalysisTemplate.full     ...
    = fullfile(options.eeg.batchesroot, 'fullfactorial.m');
options.eeg.secondlevelDataType ...
    = 'sensor_';
options.eeg.secondlevelAnalysisType ...
    = 'classical';
options.eeg.secondlevelStatsThreshold = 'clusterFWE'; %peakFWE

%% Second level arrays
switch lower(options.eeg.firstLevelDesignName)
    case {'PEs'}
        options.eeg.secondlevelArray  = {
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_OutcomePE'};
        options.eeg.secondlevelRegressors = ...
            {'CuePE','OutcomePE'};
    case {'default', 'full'}
        options.eeg.secondlevelArray  = {
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_SignedDelta1',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Precision2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Precision3',...
            'FullDesignMatrix_Delta3'};
        options.eeg.secondlevelRegressors = ...
            {'CuePE','SignedDelta1','OutcomePE','Precision2','Delta2',...
            'Precision3','Delta3'};
    case 'hgf'
        options.eeg.secondlevelArray  = {'FullDesignMatrix_Main',...
            'FullDesignMatrix_Delta1',...
            'FullDesignMatrix_Precision2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Precision3',...
            'FullDesignMatrix_Delta3'};
        options.eeg.secondlevelRegressors = ...
            {'Main', 'Delta1','Precision2','Delta2',...
            'Precision3','Delta3'};
    case 'uncertainty'
        options.eeg.secondlevelArray  = {'FullDesignMatrix_Main',...
            'FullDesignMatrix_CuePE',...
            'FullDesignMatrix_SignedDelta1',...
            'FullDesignMatrix_OutcomePE',...
            'FullDesignMatrix_Sigma2',...
            'FullDesignMatrix_Delta2',...
            'FullDesignMatrix_Sigma3'};
        options.eeg.secondlevelRegressors = ...
            {'Main', 'CuePE','SignedDelta1','OutcomePE','Sigma2','Delta2',...
            'Sigma3'};
end

%% EEG Logging options --------------------------------------------------------%
options.eeg.log.errorfile       = fullfile(options.eeg.preproc.grouproot, 'errorLog.mat');
options.eeg.log.diarygroupfile  = fullfile(options.eeg.preproc.grouproot, 'diary_AllSubjects.log');
options.eeg.log.optionssavefile = fullfile(options.eeg.preproc.grouproot, 'optionsAsExecuted.mat');

pathNow = pwd;
% only works for linux so far
cd(options.roots.code);
[~,stringCommit] = system('git log| head -1');
stringCommit(end) = []; % remove trailing end of line
stringCommit(1:7) = []; % remove 'commit '
cd(pathNow);

options.eeg.log.commithash      = stringCommit;
options.eeg.log.commitstringfile = fullfile(options.eeg.preproc.grouproot, ...
    sprintf('commit.%s.txt', options.eeg.log.commithash));


%% EEG Representational Code (Output Figures for paper)
options.eeg.representation.pathFigures.classical = fullfile(options.eeg.secondlevelDir.classical, 'Figure3Pngs');
options.eeg.representation.meanbetawavefile = fullfile(options.eeg.representation.pathFigures.classical, ...
    [options.eeg.part '_' 'MeanBetaWaveBlobsSensor.png']);
options.eeg.representation.meanerpwavefile = fullfile(options.eeg.representation.pathFigures.classical, ...
    [options.eeg.part '_' 'MeanERPWaveSensor.png']);
options.eeg.representation.pathFiguresSortedTrials = fullfile(options.eeg.secondlevelDir.classical, 'FigureS1Pngs');

options.eeg.representation.originbeta = 'image'; % other option: channel

% 't'or 'F', defining which contrast type is used for the blobs
% in figure 3, the temporal hierarchy; and the mean beta waveform plot
options.eeg.representation.blobContrastType = 'F' ;
options.eeg.representation.FContrastArray = [1 1 1 1 1 1];
options.eeg.representation.TContrastArray = [3 3 3 5 3 5];

%% EEG Plot sorted trials options

% otherwise, set parameters manually
options.eeg.representation.plotSortedTrials.doSubtractFirstTimePointEeg = false; % to see whether it makes plots nicer

% since in GLM, mean is also removed by extra regressors, absolute
% values of quantities betweeen subjects have no meaning
options.eeg.representation.plotSortedTrials.doSubtractSubjectMeanQuantity = true;

% If the beta value itself (i.e. the multiplicative coupling between
% quantitity time course and EEG amplitude) can vary between subjects, i.e.
% we assume a random effect (instead of a fixed effect where beta should be
% the same for all subjects), a z-transform is in order, since it removes
% the global scaling of the quantity.
% Mind you, this will then only reveal the link of relative changes for the
% quantitity within each subject, but between-subject scaling of the coupling
% vs different quantity fluctuation amplitudes on the behav level between
% subjects can not be distinguished
options.eeg.representation.plotSortedTrials.doZTransformSubjectQuantity     = false;

% in general trafo of EEG data should match that of quantity before
% sorting, because only then effects can be seen that were detected in
% GLM by sorting EEG data. This corresponds to a plotting of time
% series "adjusted" for contrasts (regressors) in SPM's fMRI results
% GUI, i.e., projection of data via a residual forming matrix of the
% regressors of no interest for this sorting, e.g., the mean.
options.eeg.representation.plotSortedTrials.doSubtractSubjectMeanEEG = false;
options.eeg.representation.plotSortedTrials.doZTransformSubjectEEG = false;

% subtract mean value (over time window) of subject mean ERP (over trials)
% scale by std value (over time window) of subject mean ERP (over trials)
options.eeg.representation.plotSortedTrials.doScaleSubjectEEGRange = false;

% dimenson along which mean correction and z-transform will be performed
% values: 'trials' or 'timeWithinTrial';
options.eeg.representation.plotSortedTrials.dimensionEEGTransforms = 'timeWithinTrial';

% for top row plots quantities are also sorted within subjects by their magnitude
options.eeg.representation.plotSortedTrials.doSortPerSubjectQuantity        = true;
options.eeg.representation.plotSortedTrials.doAverageSlidingWindowTrials    = true;
% Stefanics et al. had 3000 for 280.000 trials, we scale accordingly with our 9800+ trials
options.eeg.representation.plotSortedTrials.nTrialsSlidingWindow            = 3e3/2.8e5*9.843e3;
options.eeg.representation.plotSortedTrials.doSaveFigs                      = true;
options.eeg.representation.plotSortedTrials.doPlotMaximumChannel            = true;
% for shaded ERP plot, taking mean/std of within these percentile ranges
options.eeg.representation.plotSortedTrials.lowerPercentileRange            = [0 50];
options.eeg.representation.plotSortedTrials.upperPercentileRange            = [50 100];

if options.eeg.representation.plotSortedTrials.doPlotMaximumChannel
    
    options.eeg.representation.plotSortedTrials.channelArray    = {
        {'58'}
        {'5'};
        {'81'};
        {'73'};
        {'73'};
        {'8'};
        };
end



% EEG Create directories needed for successful execution ---------------------%
% mkdir(options.eeg.representation.pathFigures.classical);
% mkdir(options.eeg.representation.pathFiguresSortedTrials);
% mkdir(options.eeg.secondlevelDir.classical); % creates also 2ndlevel dir with it
% mkdir(options.eeg.secondlvl_source_erpfold);
% mkdir(options.eeg.secondlvl_erpfold);

% save options to file
save(options.eeg.log.optionssavefile, 'options');