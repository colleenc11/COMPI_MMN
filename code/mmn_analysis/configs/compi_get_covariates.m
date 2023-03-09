function [covars] = compi_get_covariates(options,IDs)


%% Main
% Read data
T = readtable(fullfile(options.roots.data, 'clinical', 'input_mask_LM_summed.xlsx'));


%% Collect Covariates

age             = NaN(length(IDs),1);
wm              = NaN(length(IDs),1);
ed_yrs          = NaN(length(IDs),1);
antipsych       = NaN(length(IDs),1);
antidep         =  NaN(length(IDs),1);
panss_pos_T0    =  NaN(length(IDs),1);
GF_social_T0    =  NaN(length(IDs),1);
GF_role_T0      =  NaN(length(IDs),1);
GF_total_T0     =  NaN(length(IDs),1);

for idx = 1:length(IDs)

    if IDs{idx} == '0139'
        row = strcmp(T.id, ['COMPI_' IDs{idx} '_2']);
    else
        row = strcmp(T.id, ['COMPI_' IDs{idx}]);
    end
    
    age(idx)            = T.SocDem_age(row);
    wm(idx)             = T.DS_backward(row);
    ed_yrs(idx)         = T.SocDem_education_years_total(row);
    antipsych(idx)      = T.medication_antipsych_T0(row);
    antidep(idx)        = T.medication_antidep_T0(row);
    panss_pos_T0(idx)   = T.PANSS_P_SUM_T0(row);
    GF_social_T0(idx)   = T.GF_social_T0(row);
    GF_role_T0(idx)     = T.GF_role_T0(row);
    GF_total_T0(idx)     = T.GF_total_T0(row);

end

% take z-score
covars_z = zscore([GF_social_T0],[],1);

% convert to table
covars = array2table([covars_z]);
covars.Properties.VariableNames = {'GF_social_T0'};



% covars = array2table([age wm antipsych antidep, panss_pos_T0]);
% covars.Properties.VariableNames = {'age', 'wm', 'antipsych', 'antidep', 'panss_pos_T0'};