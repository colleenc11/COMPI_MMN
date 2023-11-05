function compi_2ndlevel_analysis_with_demographic_covariates(options)
%--------------------------------------------------------------------------
% COMPI_2NDLEVEL_ANALYSIS_WITH_DEMOGRAPHIC_COVARIATES Run model-based and 
% erp analysis with demographic covariates in the COMPI study.
%   IN:     options - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

% general analysis options
if nargin < 1
    options = compi_mmn_options;
end

%% Main
% Additional covariates
covariate_list = ...
   {{'SocDem_age'}, {'SocDem_cannabis_T0'}, {'DS_backward'}, ...                        % Age, Cannabis, Working Memory
    {'GF_role_T0', 'SocDem_age'}, {'GF_social_T0', 'SocDem_age'}, ...                   % GF & Age
    {'GF_role_T0', 'SocDem_cannabis_T0'}, {'GF_social_T0', 'SocDem_cannabis_T0'}, ...   % GF & Cannabis
    {'GF_role_T0', 'DS_backward'}, {'GF_social_T0', 'DS_backward'}};                    % GF & Working Memory

condition_list = ...
   {'HC_Age', 'HC_Cannabis', 'HC_WM', ...               % Age, Cannabis, Working Memory
    'HC_GFRole_Age', 'HC_GFSocial_Age', ...             % GF & Age
    'HC_GFRole_Cannabis', 'HC_GFSocial_Cannabis', ...   % GF & Cannabis
    'HC_GFRole_WM', 'HC_GFSocial_WM'};                  % GF & Working Memory

% loop through covariates and GLM designs
for i = 1:length(covariate_list)

    options.condition = char(condition_list{i});
    options.eeg.covar.include = 1;
    options.eeg.covar.covariate_names = {covariate_list{i}};
    
    % Model-Based Analysis
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

    % ERP-Based Analysis
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