function compi_2ndlevel_erpbased(options)
%--------------------------------------------------------------------------
% Performs all 2nd level analyses steps for modelfree ERP single-trial 
% EEG analysis
%--------------------------------------------------------------------------

% Loop over each regressor and compute ERP analysis per group and compute
% group differences for each regressor

% loop over groups
for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});

    switch options.eeg.type
        case 'sensor'
%             compi_2ndlevel_erpanalysis_percondition(options);
            compi_2ndlevel_erpstats_percondition(options);
        case 'source'
            compi_2ndlevel_erpsource_percondition(options);
    end
end


% compute group difference
if length(options.subjects.group_labels) == 2
    switch options.eeg.type
        case 'sensor'
%             compi_2ndlevel_erpanalysis_groupdiff(options);
            compi_2ndlevel_erpstats_groupdiff(options);
        case 'source'
            compi_2ndlevel_erpsource_groupdiff(options);
    end
end


end
