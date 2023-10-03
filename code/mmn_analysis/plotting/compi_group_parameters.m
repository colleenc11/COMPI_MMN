function groupHGFParamTable = compi_group_parameters( options )
%--------------------------------------------------------------------------
% COMPI_GROUP_PARAMETERS Creates a table summarizing the average initial
% HGF perceptual parameters
% 
%   IN:     options             - the struct that contains all analysis options
%   OUT:    groupHGFParamTable  - output table of HGF parameters
%--------------------------------------------------------------------------

if nargin < 1
    options = compi_mmn_options;
end

mkdir(fullfile(options.roots.diag_eeg, 'TableS1'));

% loop through conditions
for i_group = 1:length(options.subjects.group_labels)
    options.condition = char(options.subjects.group_labels{i_group});

     % loop through subjects and get their stats
     for iSub = 1: length(options.subjects.IDs{i_group})
        subID = char(options.subjects.IDs{i_group}{iSub});
        details = compi_get_subject_details(subID, options);
        load(fullfile(details.dirs.preproc, 'bopars.mat'));

        om_2(iSub) = bopars.p_prc.om(2);
        om_3(iSub) = bopars.p_prc.om(3);

        sa0_2(iSub) = bopars.p_prc.sa_0(2);
        sa0_3(iSub) = bopars.p_prc.sa_0(3);        

     end

    % table
    groupHGFParamTable = table(om_2', ...
                            om_3', ...
                            sa0_2',...
                            sa0_3',  ...
                            'RowNames', options.subjects.IDs{i_group}', ...
                            'VariableNames', {'om_2', ...
                            'om_3', ...
                            'sa0_2',...
                            'sa0_3'});

    save(fullfile(options.roots.diag_eeg, 'TableS1', [options.condition '_HGFParamTable']), 'groupHGFParamTable');

    clear om_2
    clear om_3
    clear sa0_2
    clear sa0_3
end

end