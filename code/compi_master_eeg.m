% -------------------------------------------------------------------------
% Main COMPI MMN Script for EEG data
% Adapted from main_ioio_eeg
% Author: Colleen Charlton
% ------------------------------------------------------------------------- 
 
%% Set paths
compi_setup_paths();

%% Set options
options = compi_mmn_options([3 1 1 2 2 3 2 2 2 2]);

% PREPROC ARRAY OPTIONS
% badTrialsThreshold              = {'80', '100', '75'};
% eyeDetectionThreshold           = {'subject-specific', 'default'};
% eyeCorrectionMethod             = {'SSP', 'Berg', 'reject','PSSP'};
% eyeCorrectionComponentsNumber   = {'3', '1', '2'};
% downsample                      = {'no', 'yes'};
% lowpass                         = {'45', '35', '30'};
% baseline                        = {'0', '1'};
% smoothing                       = {'no', 'yes'};
% digitization                    = {'subject-specific', 'template'};
% highpass                        = {'0.5', '0.1'};

%% Behavioral Analysis
%  ------------------------------------------------------------------------
%  Analysis of visual distraction task
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running behavioral analysis:\n\n');

compi_mmn_plot_behavior(options);

% Note: one subject had hit-rate below 75%. There was no significant
% difference in results with and without the subject. To run the following 
% analyses without this subject, uncomment the following line of code. 

% behavExcludedIDs = {'0141'};
% options.subjects.all = setdiff(options.subjects.all,...
%         behavExcludedIDs, 'stable');
% for i = 1:length(options.subjects.group_labels)
%     options.subjects.IDs{i} = setdiff(options.subjects.IDs{i},...
%         behavExcludedIDs, 'stable');
% end 

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
%  Second level: Model Based Analysis
%  Note: both sensor and source analysis performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level model-based analysis with HCs: \n\n');

options.condition = 'HC';
options.eeg.covar.include = 0;

for i_des = 1:length(options.eeg.stats.design_types)

    design = options.eeg.stats.design_types{i_des};
    options = compi_get_design_regressors(design, options);

    % sensor-level analysis
    options.eeg.type = 'sensor';
    compi_2ndlevel_singletrial_percondition(options);

    % source-level analysis
    options.eeg.type = 'source';
    compi_2ndlevel_singletrial_percondition(options);

end

%% ------------------------------------------------------------------------
%  Second level: ERP Based Analysis
%  Note: both sensor and source analysis performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level ERP-based analysis with HCs: \n\n');

options.condition = 'HC';
options.eeg.covar.include = 0;

for i_des = 1:length(options.eeg.erp.design_types)

    design = options.eeg.erp.design_types{i_des};
    options = compi_get_design_regressors(design, options);

    % sensor-level analysis
    options.eeg.type = 'sensor';
    compi_2ndlevel_erpanalysis_percondition(options);
    compi_2ndlevel_erpstats_percondition(options);

    % source-level analysis
    options.eeg.type = 'source';
    compi_2ndlevel_erpsource_percondition(options);

end

%% ------------------------------------------------------------------------
%  Second level: Model Based Analysis with GF Covariates
%  Note: both sensor and source analysis being performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level model-based covariate analysis: \n\n');

% Main covariates
covariate_list = {{'GF_role_T0'}, {'GF_social_T0'}};
condition_list = {'HC_GFRole', 'HC_GFSocial'};

% loop through covariates and GLM designs
for i = 1:length(covariate_list)

    options.condition = char(condition_list{i});
    options.eeg.covar.include = 1;
    options.eeg.covar.covariate_names = {covariate_list{i}};
    
    for i_des = 1:length(options.eeg.stats.design_types)
    
        design = options.eeg.stats.design_types{i_des};
        options = compi_get_design_regressors(design, options);

        % sensor-level analysis
        options.eeg.type = 'sensor';
        compi_2ndlevel_singletrial_percondition(options);
    
        % source-level analysis
        options.eeg.type = 'source';
        compi_2ndlevel_singletrial_percondition(options);

    end
end

%% ------------------------------------------------------------------------
%  Second level: ERP Based Analysis with GF Covariates
%  Note: both sensor and source analysis being performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level ERP-based covariate analysis: \n\n');

% Main covariates
covariate_list = {{'GF_role_T0'}, {'GF_social_T0'}};
condition_list = {'HC_GFRole', 'HC_GFSocial'};

% loop through covariates and GLM designs
for i = 1:length(covariate_list)

    options.condition = char(condition_list{i});
    options.eeg.covar.include = 1;
    options.eeg.covar.covariate_names = {covariate_list{i}};
    
    for i_des = 1:length(options.eeg.erp.design_types)
    
        design = options.eeg.erp.design_types{i_des};
        options = compi_get_design_regressors(design, options);

        % sensor-level analysis
        options.eeg.type = 'sensor';
        compi_2ndlevel_erpstats_percondition(options);
    
        % source-level analysis
        options.eeg.type = 'source';
        compi_2ndlevel_erpsource_percondition(options);

    end
end

%% ------------------------------------------------------------------------
%  Second level: Model & ERP Based Analysis with additional covariates
%  Note: both sensor and source analysis being performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level model-based covariate analysis: \n\n');

compi_2ndlevel_analysis_with_demographic_covariates(options);


%% ---------------------------------------------------------------------
%  Paper Figures
%  ---------------------------------------------------------------------

compi_create_paper_figures(options);

