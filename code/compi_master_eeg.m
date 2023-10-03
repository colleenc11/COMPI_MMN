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
%  First level: Behavioral Analysis and modeling
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running the first level behavioral analysis:\n\n');

compi_mmn_plot_behavior(options);

% Note: one subject had hit-rate below 75%. There was no significant
% difference in results with and without the subject. To run the following 
% analyses without this subject, uncomment the following line of code. 

% behavExcludedIDs = {'0141'};
% options.subjects.all = setdiff(options.subjects.all,...
%         behavExcludedIDs, 'stable');
% for i = 1:length(options.subjects.group_labels)
%     options.subjects.group{i} = setdiff(options.subjects.IDs{i},...
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
%  Second level: Second-Level Model Based Analysis with Covariates
%  Note: both sensor and source analysis being performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level model-based covariate analysis: \n\n');

covariate_list = {'GF_role_T0', 'GF_social_T0'}; %'SocDem_age', 'SocDem_sex_binary'
condition_list = {'HC_GFRole', 'HC_GFSocial'}; %'HC_age', 'HC_sex'

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
%  Second level: ERP Based Analysis with Covariates
%  Note: both sensor and source analysis being performed here.
%  ------------------------------------------------------------------------
fprintf('\n===\n\t Running second level ERP-based covariate analysis: \n\n');

covariate_list = {'GF_role_T0', 'GF_social_T0'}; %'SocDem_age', 'SocDem_sex_binary',
condition_list = {'HC_GFRole', 'HC_GFSocial'}; %'HC_age', 'HC_sex'

covariate_list = {{'GF_role_T0', 'SocDem_cannabis_T0'}, {'GF_social_T0', 'SocDem_cannabis_T0'}}; %'SocDem_age', 'SocDem_sex_binary'
condition_list = {'HC_GFRole_can', 'HC_GFSocial_can'}; %'HC_age', 'HC_sex'

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

%% ---------------------------------------------------------------------
%  Figures: Sensor-Level
%  ---------------------------------------------------------------------

% Create ERP figures for model regressors
design_matrix = {'epsilons', 'lowPE', 'highPE'};
for i_des = 1:length(design_matrix)

    design = design_matrix{i_des};
    options = compi_get_design_regressors(design, options);

    compi_2ndlevel_erpanalysis_percondition(options);
end

% Plot sensor results
compi_results_report_modelbased(options);

%% ---------------------------------------------------------------------
%  Figures: Source-Level
%  ---------------------------------------------------------------------


% plot source waveforms (model-based)
for i_des = 1:length(options.eeg.erp.design_types)

    design = options.eeg.stats.design_types{i_des};
    options = compi_get_design_regressors(design, options);

    for i_reg = 1:length(options.eeg.stats.regressors)
        
        factor = options.eeg.stats.regressors{i_reg};
        compi_plot_source_waveforms_as_subplots(factor, options);
    end
end

% plot source waveforms (ERP)
for i_des = 1:length(options.eeg.erp.design_types)

    design = options.eeg.erp.design_types{i_des};
    options = compi_get_design_regressors(design, options);

    for i_reg = 1:length(options.eeg.stats.regressors)
        
        factor = options.eeg.stats.regressors{i_reg};
        compi_plot_source_waveforms_as_subplots(factor, options);
    end
end

%%
% Figure 4A -------------------------------------------------------------
factor = 'oddball';
timewindow = [301 309];
compi_plot_source_ppm(timewindow, factor, options);

tPeak = 305;
sourceToFind = 'MSP_rightA1';
covar = {'GF_role_T0'};
compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options);

% Figure 4B -------------------------------------------------------------
factor = 'oddball_volatile';
timewindow = [344 400];
compi_plot_source_ppm(timewindow, factor, options);

tPeak = 398;
sourceToFind = 'MSP_rightIFG';
covar = {'GF_social_T0'};
compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options);

%%
% Figure S4A -------------------------------------------------------------
factor = 'delta1';
timewindow = [137 180];
compi_plot_source_ppm(timewindow, factor, options);

tPeak = 156;
sourceToFind = 'MSP_rightSTG';
covar = {'GF_role_T0'};
compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options);

factor = 'delta2';
timewindow = [145 176];
compi_plot_source_ppm(timewindow, factor, options);

tPeak = 156;
sourceToFind = 'MSP_rightSTG';
covar = {'GF_role_T0'};
compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options);

% Figure S4B -------------------------------------------------------------
factor = 'psi3';
timewindow = [242 270];
compi_plot_source_ppm(timewindow, factor, options);

tPeak = 254;
sourceToFind = 'MSP_leftA1';
covar = {'GF_social_T0'};
compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options);

%% Figure 3: Beta vs. GF Score Plots
% GF: Role
covariate = {'GF_role_T0'};

mask = fullfile(options.roots.erp, 'GF_Mask', 'MMN_GFRole_Cluster.nii');
options = compi_get_design_regressors('oddball', options);
compi_plot_covar_vs_betas(covariate, mask, options);

mask = fullfile(options.roots.erp, 'GF_Mask', 'stableMMN_GFRole_Cluster.nii');
options = compi_get_design_regressors('oddball_stable', options);
compi_plot_covar_vs_betas(covariate, mask, options);

% GF: Social
covariate = {'GF_social_T0'};

mask = fullfile(options.roots.erp, 'GF_Mask', 'MMN_GFSocial_Cluster.nii');
options = compi_get_design_regressors('oddball', options);
compi_plot_covar_vs_betas(covariate, mask, options);

mask = fullfile(options.roots.erp, 'GF_Mask', 'volatileMMN_GFSocial_Cluster.nii');
options = compi_get_design_regressors('oddball_volatile', options);
compi_plot_covar_vs_betas(covariate, mask, options);


%% ---------------------------------------------------------------------
%  Other
%  ---------------------------------------------------------------------

% Table S1:
groupHGFParamTable=compi_group_parameters( options );

% calculate design collinarity
compi_calculate_design_collinearity(options)



