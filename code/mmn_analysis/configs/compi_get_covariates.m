function [covar_table] = compi_get_covariates(covariate_list, subject_IDs, options, do_zscore)
%--------------------------------------------------------------------------
% COMPI_GET_COVARIATES Returns specific covariates for subjects 
% specified in subject_IDs.
%
%   IN:     covariate_list     list of covariates of interest
%           subject_IDs        subject ids we want covariates for
%           options            as set by mnCHR_set_analysis_options();
%           zscore             whether to take zscore of covars (default 1)
%   OUT:    -
%--------------------------------------------------------------------------

% general analysis options
if nargin < 4
    do_zscore = 1;
end

%% Read data
T = readtable(fullfile(options.roots.data, 'clinical', 'input_mask_LM_summed.xlsx'));

%% Collect subject IDs
all_IDs = table2array(T(:,1));

%% Initialize covariate structure
covariate_struct = struct();

%% Collect covariates
% Loop through covariates for each subject
for i_cov = 1:length(covariate_list{1,1})
    % current_covariate = char(covariate_list{i_cov});
    current_covariate = char(covariate_list{1,1}(i_cov));

    for idx = 1:length(subject_IDs)
        
        % Find subject in data table
        for i_row = 1:numel(all_IDs)
            if find(strcmp(all_IDs{i_row}(end-3:end), subject_IDs{idx})) 
                % match found, do something
                row = i_row;
                break
            end
        end
        
        % Get covariates
        covariate_struct.(current_covariate)(idx) = (T{row, strcmp(T.Properties.VariableNames, current_covariate)})';
    
    end

    % Take z-score of covariate
    if do_zscore  
        covariate_struct.(current_covariate) = zscore(covariate_struct.(current_covariate)', [], 1); 
    end
end

%% Write output table
covar_table = struct2table(covariate_struct);

% Set VariableNames for each covariate
% covar_table.Properties.VariableNames = covariate_list{1,1};
% covar_table.Properties.VariableNames = {char(covariate_list{1,1}(1)), char(covariate_list{1,1}(2))};

end