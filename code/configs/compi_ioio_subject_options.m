function [options] = compi_ioio_subject_options(options)
%--------------------------------------------------------------------------
% Augments options with list of subjects that need to be included in the
% analysis.
%--------------------------------------------------------------------------

%% Set groups

CHR = {...
    '0051','0052','0053','0054','0055','0056','0057','0058','0059',...
    '0060','0061','0062','0063','0064','0066','0067','0068','0069',...
    '0070'...
    };
HC = {...
    '0101','0102','0103','0104','0105','0106','0107','0108','0109',...
    '0110','0111','0112','0113','0114','0115','0116','0117','0118','0119',...
    '0120','0121','0122','0123','0124','0125','0126','0127','0128','0129',...
    '0130','0131','0132','0133','0134','0135','0136','0137','0138','0139',...
    '0140','0141','0142','0143'...
    };

% options.subjects.eeg_1st = {...
%     '0001','0002','0003','0004','0005','0006','0007','0008','0009',...
%     '0010','0011','0012','0013','0014','0015','0016','0017','0018',...
%     '0052','0053','0056',...
%     '0061','0062','0064','0065','0068','0069','0070',...
%     '0101','0102','0103','0106','0107','0108','0109',...
%     '0111','0114','0115','0116','0118','0119',...
%     '0120','0122','0123','0125','0128',...
%     '0130','0131','0132','0133','0134','0135','0137',...
%     '0141',...
%     };

%% Set missing subjects

switch options.analysis.type
    case 'all'
        missing = {'0055'}; % dropped out

    case 'hc'
        missing = {};
                    
    case 'matched'
        % Exclude subjects that were NOT selected to match CHR
        missing = setdiff(HC,{
            '0101', '0102', '0104', '0106', '0107', '0108', '0109',...
            '0113', '0115', '0117', '0118', '0123', '0124', '0129',...
            '0131', '0134', '0137', '0141'})';
        
        missing{end+1} = '0055'; % dropped out
end

switch lower(options.analysis.type)
    case 'all'
        options.subjects.all = setdiff([HC CHR], missing, 'stable');

        % Output groups
        options.subjects.group_labels = {'HC','CHR'};
        options.subjects.IDs{1} = setdiff(HC, missing , 'stable');
        options.subjects.IDs{2} = setdiff(CHR, missing, 'stable');

    case 'matched'
        options.subjects.all = setdiff([HC CHR], missing, 'stable');

        % Output groups
        options.subjects.group_labels = {'HC','CHR'};
        options.subjects.IDs{1} = setdiff(HC, missing , 'stable');
        options.subjects.IDs{2} = setdiff(CHR, missing, 'stable');

    case 'hc'
        options.subjects.all = setdiff(HC, missing , 'stable');

        % Output groups
        options.subjects.group_labels = {'HC'};
        options.subjects.IDs{1} = setdiff(HC, missing , 'stable');
end


end