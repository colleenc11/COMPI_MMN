% -------------------------------------------------------------------------
% Main COMPI MMN Script for EEG data
% Adapted from main_ioio_eeg
% Author: Colleen Charlton
% ------------------------------------------------------------------------- 
 
%% Set paths
compi_setup_paths();

%% Set options
options = compi_mmn_options([3 1 1 2 2 3 2 2 2 2], 'PEs');

% PREPROC ARRAY OPTIONS
% badTrialsThreshold              = {'80', '100', '75'};
% eyeDetectionThreshold           = {'subject-specific', 'default'};
% eyeCorrectionMethod             = {'SSP', 'Berg', 'reject','PSSP'};
% eyeCorrectionComponentsNumber   = {'3', '1'};
% downsample                      = {'no', 'yes'};
% lowpass                         = {'45', '35', '30'};
% baseline                        = {'0', '1'};
% smoothing                       = {'no', 'yes'};
% digitization                    = {'subject-specific', 'template'};
% highpass                        = {'0.5', '0.1'};

%% Behavioral Analysis
%  ------------------------------------------------------------------------
%  First level: Behavioral Analysis and modeling
%  ------------------------------------------------------------------------
% fprintf('\n===\n\t Running the first level analysis:\n\n');
% compi_ioio_behav_analysis(options);

% compi_create_matched_groups(options);

%% Preprocessing
% ---------------------------------------------------------------------------------
%  First level: EEG Preprocessing, ERP Analysis, Image Conversion and 1st-Level GLM
% ---------------------------------------------------------------------------------
fprintf('\n===\n\t Preprocessing EEG:\n\n');

compi_loop_analyze_subject(options);


%% ------------------------------------------------------------------------
%  Quality Check
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Quality check EEG:\n\n');

compi_quality_check(options);

%% ------------------------------------------------------------------------
%  Second level: Model Based
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level model-based analysis: \n\n');

compi_2ndlevel_modelbased(options);

%% ------------------------------------------------------------------------
%  Second level: Group Phase ERP
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level ERP-based analysis:\n\n');

compi_2ndlevel_erpbased(options);

%% ------------------------------------------------------------------------
%  Figures
%  ------------------------------------------------------------------------

tayeeg_results_report_modelbased(options);
