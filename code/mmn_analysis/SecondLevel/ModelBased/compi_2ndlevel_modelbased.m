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
    compi_2ndlevel_singletrial_percondition(options);
end

compi_2ndlevel_singletrial_groupdiff(options);

end