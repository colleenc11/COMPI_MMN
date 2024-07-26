function [options] = compi_mmn_subject_options(options)
%--------------------------------------------------------------------------
% COMPI_MMN_SUBJECT_OPTIONS Augments options with list of subjects that 
% need to be included in the analysis.
%--------------------------------------------------------------------------

%% Set groups

HC = {...
    '0101','0102','0103','0104','0105','0106','0107','0108','0109',...
    '0110','0111','0112','0113','0114','0115','0116','0117','0118','0119',...
    '0120','0121','0122','0123','0124','0125','0126','0127','0128','0129',...
    '0130','0131','0132','0133','0134','0135','0136','0137','0138','0139',...
    '0140','0141','0142','0143'...
    };


%% Set missing subjects

switch lower(options.analysis.type)
    case 'hc'
        missing = {}; %'0141'
end

switch lower(options.analysis.type)
    case 'hc'
        options.subjects.all = setdiff(HC, missing , 'stable');

        % Output groups
        options.subjects.group_labels = {'HC'};
        options.subjects.IDs{1} = setdiff(HC, missing , 'stable');
end


end