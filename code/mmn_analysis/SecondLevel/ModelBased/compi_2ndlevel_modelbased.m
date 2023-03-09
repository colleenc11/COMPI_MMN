function compi_2ndlevel_modelbased(options)
%--------------------------------------------------------------------------
% Performs all 2nd level analyses steps for modelbased single-trial 
% EEG analysis
%--------------------------------------------------------------------------

if nargin < 1
    options = compi_set_analysis_options;
end 
    
% loop over groups
for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});

    switch options.eeg.type
        case 'sensor'
            compi_2ndlevel_singletrial_percondition(options);
        case 'source'
            compi_2ndlevel_singletrial_source(options);
    end
end

% compute group difference
if length(options.subjects.group_labels) == 2
    switch options.eeg.type
        case 'sensor'
            compi_2ndlevel_singletrial_groupdiff(options);
        case 'source'
            compi_2ndlevel_singletrial_source_groupdiff(options);
    end
end


end