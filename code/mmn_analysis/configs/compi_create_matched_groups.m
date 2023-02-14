function compi_create_matched_groups(options)
%--------------------------------------------------------------------------
% Create matched HC group for COMPI MMN study.
%--------------------------------------------------------------------------

%% Create random numbers
rng(1)
randNumbers = randi([1, 42], 1, 18);
randNumbers = unique(randNumbers);
while length(randNumbers) < 18
    newNumber = randi([1, 42]);
    if ~ismember(newNumber, randNumbers)
        randNumbers = [randNumbers, newNumber];
    end
end


% select subjects
HC_ids  = options.subjects.IDs{1}(randNumbers);
CHR_ids = options.subjects.IDs{2};
all_ids = [HC_ids, CHR_ids];

%% Check if covariates are matched
% Read data
T = readtable(fullfile(options.roots.data, 'clinical', 'input_mask_LM_summed.xlsx'));

% Collect covariates
age             = NaN(length(all_ids),1);
wm              = NaN(length(all_ids),1);
ed_yrs          = NaN(length(all_ids),1);
gender          = NaN(length(all_ids),1);
handedness      = NaN(length(all_ids),1);
cannabis        = NaN(length(all_ids),1);

for idx = 1:length(all_ids)
    if all_ids{idx} == '0139'
        row = strcmp(T.id, ['COMPI_' all_ids{idx} '_2']);
    else
        row = strcmp(T.id, ['COMPI_' all_ids{idx}]);
    end
    
    age(idx)            = T.SocDem_age(row);
    wm(idx)             = T.DS_backward(row);
    ed_yrs(idx)         = T.SocDem_education_years_total(row);
    gend                = T.SocDem_sex(row);
    gender(idx)         = gend{1};
    hand                = T.SocDem_handedness(row);
    handedness(idx)     = hand{1};
    cannabis(idx)       = T.drug_test_pos(row);
end

% convert to table
covars = array2table([age wm ed_yrs gender handedness cannabis]);
covars.Properties.VariableNames = {'age', 'wm', 'ed_yrs', 'gender', 'handedness', 'cannabis'};

%% Test for statistical differences
[h_age,~]       = ttest2(covars.age(1:18), covars.age(19:end));
[h_wm,~]        = ttest2(covars.wm(1:18), covars.wm(19:end));
[h_ed_yrs,~]    = ttest2(covars.ed_yrs(1:18), covars.ed_yrs(19:end));

[h_gender,~]            = ttest2(covars.gender(1:18), covars.gender(19:end));
[h_handedness,~]        = ttest2(covars.handedness(1:18), covars.handedness(19:end));
[h_cannabis,~]          = ttest2(covars.cannabis(1:18), covars.cannabis(19:end));

%% Save matched IDs


end


