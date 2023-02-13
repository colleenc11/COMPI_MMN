function [options] = compi_ioio_subject_options(options)



% ----------------------
% Set groups
% ----------------------
FEP = {...
    '0001','0002','0003','0004','0005','0006','0007','0008','0009',...
    '0010','0011','0012','0013','0014','0015','0016','0017','0018'...
    };
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

% ----------------------
% Set missing subjects
% ----------------------
switch options.task.type
    case 'mmn'
        switch options.task.modality
            case 'eeg'
%                 Exclude subjects that were not selected to match CHR
%                 missing = setdiff(HC,{
%                     '0101', '0103','0107','0113','0115','0116','0117','0120',...
%                     '0122','0123','0129','0130','0131','0134',...
%                     '0135', '0139', '0142', '0143'})'; %'0126','0136'
%                 missing{end+1} = '0055'; % dropped out
% 
%                 missing{end+1} = '0059'; % dropped out
%                 missing{end+1} = '0067'; % dropped out
%                 missing{end+1} = '0070'; % dropped out

                missing = {'0055'}; % dropped out

                % based on Weber parameters
%                 missing = {'0102', '0119', '0124', '0126', '0136'}; %, ... %less than 80% remaining trials after preproc
                            %'0125', '0134'};                           %failure to remove eye blink component

%                 missing = {'0119', '0127', '0130', '0134', '0135'};
                    
            case 'fmri'
                missing = {'0111','0130','0055'};
        end
    case 'ioio'
        switch options.task.modality
            case 'eeg'
%                 % Exclude subjects that were not selected to match CHR
%                 missing = setdiff(HC,{
%                     '0004','0103','0107','0115','0116','0117','0120',...
%                     '0122','0123','0126','0129','0130','0131','0134',...
%                     '0135','0136'})';
                % Exclude subjects with EEG recording problems
                missing = {
                    '0055' % no EEG recorded (dropout)
                    '0119' % data missing - ask Daniel!!
                    '0139' % EEG repeated
                    };
            case 'fmri'
                missing = {'0111','0130','0055'};
            case {'phase', 'hgf_comp'}
%                 missing = {
%                     '0124'  % distress hypothetically answerd
%                     '0139'  % Run 1 repeated (might still be included)
%                 };
                    
                    % Exclude subjects that were not selected to match CHR
                    missing = setdiff(HC,{
                        '0103','0107','0113','0115','0116','0117','0120',...
                        '0122','0123','0126','0129','0130','0131','0134',...
                        '0135','0136','0139',...
                        '0142','0143'});
            
            
            case 'learning_effects'
                missing = {...
                     % Exclude patients since they have only one measurement
                    '0001','0002','0003','0005','0006','0007','0008','0009',...
                    '0011','0013'...
                    '0055',...  % Dropout after MRI (no EEG)
                    '0108',...  % EEG repeated (unclear what that means for learning effects)
                    '0111',...  % no MRI (implant)
                    '0139'...   % EEG repeated after MRI (failure after run 1)
                    '0141'...   % Match for FEP (no EEG)
                    };
        end
    case 'wm'
        switch options.task.modality
            case 'eeg'
                missing = {};
            case {'behav_all','behav'}
                missing = {};
        end
end


% ----------------------
% Set EEG first
% ----------------------
options.subjects.eeg_1st = {...
    '0001','0002','0003','0004','0005','0006','0007','0008','0009',...
    '0010','0011','0012','0013','0014','0015','0016','0017','0018',...
    '0052','0053','0056',...
    '0061','0062','0064','0065','0068','0069','0070',...
    '0101','0102','0103','0106','0107','0108','0109',...
    '0111','0114','0115','0116','0118','0119',...
    '0120','0122','0123','0125','0128',...
    '0130','0131','0132','0133','0134','0135','0137',...
    '0141',...
    };

switch lower(options.subjects.groups)
    case 'all'
        options.subjects.all = setdiff([HC CHR FEP], missing, 'stable');
    case 'mmn_all'
        options.subjects.all = setdiff([HC CHR], missing, 'stable');
    case 'hc'
        options.subjects.all = setdiff(HC, missing , 'stable');
    case 'chr'
        options.subjects.all = setdiff(CHR, missing, 'stable');
    case 'fep'
        options.subjects.all = setdiff(FEP, missing, 'stable');
end


% Output groups (just in case)
options.subjects.group_labels = {'HC','CHR'};
options.subjects.IDs{1} = setdiff(HC, missing , 'stable');
options.subjects.IDs{2} = setdiff(CHR, missing, 'stable');
options.subjects.IDs{3} = setdiff(FEP, missing, 'stable');

end