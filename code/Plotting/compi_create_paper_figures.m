function compi_create_paper_figures(options)
% -------------------------------------------------------------------------
% COMPI_CREATE_PAPER_FIGURES Creates figures for research paper.
% 
%   IN:     options     Options structure as set by compi_mmn_options()
% -------------------------------------------------------------------------

%% General: create ERPs for model regressors
design_matrix = {'epsilons', 'lowPE', 'highPE'};
for i_des = 1:length(design_matrix)

    design = design_matrix{i_des};
    options = compi_get_design_regressors(design, options);

    compi_2ndlevel_erpanalysis_percondition(options);
end

%% Figure 2A: Stable MMN < Volatile MMN
options.condition               = 'HC';             % group type
options.eeg.stats.mode          = 'erpbased';       % erpbased or modelbased
options.eeg.erp.type            = 'oddball_phase';  % regressor of interest
options.eeg.fig.contrastIdx     = 2;                % contrast number 
options.eeg.stats.pValueMode    = 'peakFWE';        % stats threshold (peakFWE, clusterFWE)

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% plot stable MMN vs. volatile MMN ERPs
channel = 'C3';
compi_grandmean_plot_phase_erp(channel, options);

%% Figure 2B: Stable MMN > Volatile MMN (Sensor)
options.condition               = 'HC';
options.eeg.stats.mode          = 'erpbased'; 
options.eeg.erp.type            = 'oddball_phase';
options.eeg.fig.contrastIdx     = 1;
options.eeg.stats.pValueMode    = 'peakFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% plot stable MMN vs. volatile MMN ERPs
channel = 'T7';
compi_grandmean_plot_phase_erp(channel, options);

%% Figure 3A: MMN & GF: Social (Sensor)
options.condition               = 'HC_GFSocial';
options.eeg.stats.mode          = 'erpbased'; 
options.eeg.erp.type            = 'oddball';
options.eeg.fig.contrastIdx     = 3;
options.eeg.stats.pValueMode    = 'clusterFWE'; %peakFWE

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);


% Note, the peak coordinate needs to be in voxel space. Please extract 
% information from results in SPM GUI.

peakCoord                       = [12, 23, 56]; % mm: (-17, 24, 316)
covariate                       = {'GF_social_T0'};

compi_plot_covar_vs_sensor_betas(peakCoord, options.eeg.erp.type, covariate, options);

%% Figure 3B: MMN & GF: Role (Sensor)
options.condition               = 'HC_GFRole';
options.eeg.stats.mode          = 'erpbased'; 
options.eeg.erp.type            = 'oddball';
options.eeg.fig.contrastIdx     = 3;
options.eeg.stats.pValueMode    = 'clusterFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% Note, the peak coordinate needs to be in voxel space. Please extract 
% information from results in SPM GUI.

peakCoord                       = [6, 14, 74]; % mm: (-42, 25, 387)
covariate                       = {'GF_role_T0'};

compi_plot_covar_vs_sensor_betas(peakCoord, options.eeg.erp.type, covariate, options);

%% Figure 3C: Volatile MMN & GF: Social (Sensor)
options.condition               = 'HC_GFSocial';
options.eeg.stats.mode          = 'erpbased'; 
options.eeg.erp.type            = 'oddball_volatile';
options.eeg.fig.contrastIdx     = 3;
options.eeg.stats.pValueMode    = 'peakFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% Note, the peak coordinate needs to be in voxel space. Please extract 
% information from results in SPM GUI.

peakCoord                       = [16, 23, 63]; % mm: (0, 24, 344)
covariate                       = {'GF_social_T0'};

compi_plot_covar_vs_sensor_betas(peakCoord, options.eeg.erp.type, covariate, options);

%% Figure 3D: Stable MMN & GF: Role (Sensor)
options.condition               = 'HC_GFRole';
options.eeg.stats.mode          = 'erpbased'; 
options.eeg.erp.type            = 'oddball_stable';
options.eeg.fig.contrastIdx     = 3;
options.eeg.stats.pValueMode    = 'clusterFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% Note, the peak coordinate needs to be in voxel space. Please extract 
% information from results in SPM GUI.

peakCoord                       = [6, 14, 74]; % mm: (-42, 25, 387)
covariate                       = {'GF_role_T0'};

compi_plot_covar_vs_sensor_betas(peakCoord, options.eeg.erp.type, covariate, options);

%% Figure 4: Stable MMN & GF: Role (Source)
options.condition               = 'HC';

tPoint                          = 160;
factor                          = 'oddball_stable';
sourceToFind                    = 'MSP_leftSTG';
covar                           = {'GF_role_T0'};

% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

% create scatter plot
compi_plot_covar_vs_source_betas(tPoint, factor, sourceToFind, covar, options);

%% Figure 5: Effect of pwPEs (Sensor)

% A) low-level pwPE (epsilon2)
options.condition               = 'HC';
options.eeg.stats.mode          = 'modelbased';
options.eeg.stats.design        = 'epsilons';
options.eeg.erp.type            = 'epsilon2';
options.eeg.fig.contrastIdx     = 1;
options.eeg.stats.pValueMode    = 'peakFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% B) high-level pwPE (epsilon3)
options.eeg.erp.type            = 'epsilon3';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

%% Figure S1: Effect of unweighted PEs (Sensor)

% A) low-level PE (delta1)
options.condition               = 'HC';
options.eeg.stats.mode          = 'modelbased';
options.eeg.stats.design        = 'lowPE';
options.eeg.erp.type            = 'delta1';
options.eeg.fig.contrastIdx     = 1;
options.eeg.stats.pValueMode    = 'peakFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% B) high-level PE (delta2)
options.eeg.stats.design        = 'highPE';
options.eeg.erp.type            = 'delta2';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

%% Figure S2: Effect of precision ratio (Sensor)

% A) low-level precision ratio (psi2)
options.condition               = 'HC';
options.eeg.stats.mode          = 'modelbased';
options.eeg.stats.design        = 'lowPE';
options.eeg.erp.type            = 'psi2';
options.eeg.fig.contrastIdx     = 1;
options.eeg.stats.pValueMode    = 'peakFWE';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);

% B) high-level precision ratio (psi3)
options.eeg.stats.design        = 'highPE';
options.eeg.erp.type            = 'psi3';

compi_report_spm_results(options, options.eeg.erp.type, options.condition);
compi_plot_blobs(options, options.eeg.erp.type);
compi_extract_first_last_sig_voxel(options, options.eeg.erp.type, options.condition);


%% Figure S3: Effect of pwPEs (Source)

% A) low-level pwPE (epsilon2)
tPoint          = 180; % tWindow = [242 270]
factor          = 'epsilon2';

% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

% B) high-level pwPE (epsilon3)
tPoint          = 277; % tWindow = [242 270]
factor          = 'epsilon3';

% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

%% Figure S4: Model Parameters & Global Function Correlation (Source)

% A) GF Role & Delta 1
tPoint          = 156; % tWindow = [137 180]
factor          = 'delta1';
sourceToFind    = 'MSP_rightSTG';
covar           = {'GF_role_T0'};

% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

% create scatter plot
compi_plot_covar_vs_source_betas(tPoint, factor, sourceToFind, covar, options);

% A) GF Role & Delta 2
tPoint          = 156; % tWindow = [145 176]
factor          = 'delta2';
sourceToFind    = 'MSP_rightSTG';
covar           = {'GF_role_T0'};

% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

% create scatter plot
compi_plot_covar_vs_source_betas(tPoint, factor, sourceToFind, covar, options);

% B) GF Social & Psi 3
tPoint          = 254; % tWindow = [242 270]
factor          = 'psi3';
sourceToFind    = 'MSP_leftA1';
covar           = {'GF_social_T0'};
% create brain map from grand-average ERP
compi_grand_average_source_inversion(tPoint, factor, options);

% create scatter plot
compi_plot_covar_vs_source_betas(tPoint, factor, sourceToFind, covar, options);


%% ---------------------------------------------------------------------
%  Other
%  ---------------------------------------------------------------------

% Table S1:
groupHGFParamTable=compi_group_parameters(options);

% calculate design correlation
compi_calculate_design_correlation(options);









