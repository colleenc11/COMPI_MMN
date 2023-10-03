function compi_create_matched_groups2(options)
%--------------------------------------------------------------------------
% Create matched HC group for COMPI MMN study.
%--------------------------------------------------------------------------

%% Create random numbers
rng(1)
n = 16; % Desired number of unique random integers
range = [1, 43]; % Range of random integers

% Generate a larger range of random integers
largerRange = randi(range, 1, 50);

% Select unique values from the larger range
uniqueValues = unique(largerRange, 'stable');

% Trim the array to the desired number of unique values
% Note we don't start at 1 to match subjects
randomIntegers = uniqueValues(2:n+1);

% select subjects
HC_ids  = options.subjects.IDs{1}(randomIntegers);
CHR_ids = options.subjects.IDs{2};
subject_IDs = [HC_ids, CHR_ids];

covariate_list = {'SocDem_age', 'DS_total', 'SocDem_education_years_total', 'SocDem_sex', 'SocDem_handedness', 'SocDem_cannabis_T0'};

% covariate_list = {'PCL_freq_sum_T0', 'PCL_conv_sum_T0', 'PCL_dist_sum_T0',...
%                     'PANSS_P_SUM_T0', 'PANSS_N_SUM_T0', 'PANSS_G_SUM_T0',...
%                     'GF_social_T0', 'GF_role_T0', 'GF_total_T0'};
%% Read data
T = readtable(fullfile(options.roots.data, 'clinical', 'input_mask_LM_summed.xlsx'));

%% Collect subject IDs
all_IDs = table2array(T(:,1));

%% Initialize covariate structure
covariate_struct = struct();

%% Collect covariates
% Loop through covariates for each subject
for i_cov = 1:length(covariate_list)
    current_covariate = char(covariate_list{i_cov});

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
        if strcmp(current_covariate, 'SocDem_sex')
            covariate_struct.(current_covariate)(idx) = char(T{row, strcmp(T.Properties.VariableNames, current_covariate)});
        elseif strcmp(current_covariate, 'SocDem_handedness')
            covariate_struct.(current_covariate)(idx) = char(T{row, strcmp(T.Properties.VariableNames, current_covariate)});
        else
            covariate_struct.(current_covariate)(idx) = (T{row, strcmp(T.Properties.VariableNames, current_covariate)})';
        end
    
    end

    covariate_struct.(current_covariate) = covariate_struct.(current_covariate)'; 

end
% convert to table
covar_table = struct2table(covariate_struct);
covar_table.Properties.VariableNames = {'age', 'wm', 'ed_yrs', 'gender', 'handedness', 'cannabis'};

%covar_table.Properties.VariableNames = {'pcl_freq', 'pcl_conv', 'pcl_dist', 'panss_pos', 'panss_neg', 'panss_gen', 'gf_social', 'gf_role', 'gf_total'};

%% Test for statistical differences

[h_age,~]       = ttest2(covar_table.age(1:16), covar_table.age(17:end));
[h_wm,~]        = ttest2(covar_table.wm(1:16), covar_table.wm(17:end));
[h_ed_yrs,~]    = ttest2(covar_table.ed_yrs(1:16), covar_table.ed_yrs(17:end));

[h_gender,~]            = ttest2(covar_table.gender(1:16), covar_table.gender(17:end));
[h_handedness,~]        = ttest2(covar_table.handedness(1:16), covar_table.handedness(17:end));
[h_cannabis,~]          = ttest2(covar_table.cannabis(1:16), covar_table.cannabis(17:end));


%% Save matched IDs


end


