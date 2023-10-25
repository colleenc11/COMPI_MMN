function options = compi_mmn_preprocessing_options(preprocStrategyValueArray, options)
%--------------------------------------------------------------------------
% COMPI_MMN_PREPROCESSING_OPTIONS Preproc options for COMPI MMN study.
% IN
%       preprocStrategyValueArray   preprocessing analysis options
%       options                     (subject-independent) analysis pipeline 
%                                   options, retrieve via options = 
%                                   compi_set_analysis_options
%--------------------------------------------------------------------------

%% Set preprocessing strategy
preprocessing = compi_set_preprocessing_strategy(options.roots.results, preprocStrategyValueArray);
disp(preprocessing.selectedStrategy.valueArray);

% EEG preprocessing options
options.eeg.preprocStrategyValueArray       = preprocStrategyValueArray;
options.eeg.preproc.eyeCorrection           = true;
options.eeg.preproc.eyeCorrMethod           = ...
    preprocessing.eyeCorrectionMethod{preprocessing.selectedStrategy.valueArray(3)};

options.eeg.preproc.eyeCorrType             = 'subject-specific';

options.eeg.preproc.downsample              = preprocessing.downsample{preprocessing.selectedStrategy.valueArray(5)};
options.eeg.preproc.downsamplefreq          = 256;
options.eeg.preproc.lowpassfreq             = str2num(preprocessing.lowpass{preprocessing.selectedStrategy.valueArray(6)});
options.eeg.preproc.highpassfreq            = str2num(preprocessing.highpass{preprocessing.selectedStrategy.valueArray(10)});
options.eeg.preproc.baselinecorrection      = str2num(preprocessing.baseline{preprocessing.selectedStrategy.valueArray(7)});
options.eeg.preproc.smoothing               = preprocessing.smoothing{preprocessing.selectedStrategy.valueArray(8)};

options.eeg.preproc.mrifile                 = 'template';

%% Parameters that can be overwritten for some subjects in details
options.eeg.preproc.eyeDetectionThreshold           = preprocessing.eyeDetectionThreshold{preprocessing.selectedStrategy.valueArray(2)};% other option: default (i.e., set to 3 for all subjects)
options.eeg.preproc.eyeDetectionThresholdDefault    = 3; % for SD thresholding: in standard deviations, for amp in uV
options.eeg.preproc.nComponentsforRejection         = str2num(preprocessing.eyeCorrectionComponentsNumber{preprocessing.selectedStrategy.valueArray(4)});
options.eeg.preproc.eyeComponentThreshold           = 'subject-specific';

%% Eye blink options
options.eeg.preproc.eyeblinkmode            = 'eventbased';     % uses EEG triggers for trial onsets
options.eeg.preproc.eyeblinkwin             = [-500 500];       % in s around blink events
options.eeg.preproc.eyeblinktrialoffset     = 0.1;              % in s: EBs won't hurt <100ms after tone onset
options.eeg.preproc.eyeblinkEOGchannel      = 'VEOG';           % EOG channel (name/idx) to plot
options.eeg.preproc.eyebadchanthresh        = 0.2;              % prop of bad trials due to EBs
options.eeg.preproc.badtrialthresh          = ...
    str2num(preprocessing.badTrialsThreshold{preprocessing.selectedStrategy.valueArray(1)}); % in microVolt

options.eeg.preproc.grouproot               = preprocessing.root;
options.eeg.preproc.eyeblinkCompareSVD      = true;

%% Montage
options.eeg.preproc.montage.examplefile     = fullfile(options.roots.config, 'spmeeg_compi_VL_01.mat');
options.eeg.preproc.montage.veog            = [71 72];
options.eeg.preproc.montage.heog            = [69 70];
options.eeg.preproc.digitization            = ...
    preprocessing.digitization{preprocessing.selectedStrategy.valueArray(9)};

%% Additional Bad Trial/Bad Channel definition options
% Used for PSSP
options.eeg.preproc.artifact.badtrialthresh = 500;
options.eeg.preproc.artifact.applylowPass   = 1;        % whether to reapply low-pass filter for PSSP
options.eeg.preproc.artifact.lowPassFilter  = 10;
options.eeg.preproc.artifact.badchanthresh  = 0.2;

options.eeg.preproc.rereferencing           = 'avref';  % avref, noref
options.eeg.preproc.trialdef                = 'tone';   % tone, oddball
options.eeg.preproc.epochwin                = [-100 500]; %500

%% Steps you can turn on/off for saving/rewrite purposes
options.eeg.preproc.overwrite               = 1; % whether to overwrite any prev. prepr
options.eeg.preproc.keep                    = 1; % whether to keep intermediate data
options.eeg.preproc.keepotherchannels       = 1; % for montage

%% Conversion to images in sensor space
options.eeg.conversion.space            = 'sensor';
options.eeg.conversion.convPrefix       = 'sensor'; % whole, early, late, ERP
options.eeg.conversion.convTimeWindow   = [100 400];
options.eeg.conversion.smooKernel       = [16 16 0];
options.eeg.conversion.overwrite        = 1;


end