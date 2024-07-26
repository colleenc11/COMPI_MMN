function montage = compi_montage_swap_channels(id)
% ------------------------------------------------------------------------- 
% COMPI_MONTAGE_SWAP_CHANNELS Creates the montage struct for swapping TP7 
% and FT9 channels in the COMPI study.
%   IN:     id          - subject identifier string, e.g. '0001'
%   OUT:    montage     - the montage struct with labels and montage matrix
% ------------------------------------------------------------------------- 

montage = struct;

montage.labelorg = {
    '1-Fp1', '1-AF7', '1-AF3',	'1-F1',	'1-F3',	'1-F5',	'1-F7',	'1-FT7', ...
    '1-FC5', '1-FC3', '1-FC1', '1-C1', '1-C3', '1-C5', '1-T7', '1-TP7', ...
    '1-CP5' '1-CP3'	'1-CP1', '1-P1', '1-P3', '1-P5', '1-P7', '1-P9', '1-PO7', ...
    '1-PO3','1-O1',	'1-Iz',	'1-Oz',	'1-POz', '1-Pz', '1-CPz', '1-Fpz', ...
    '1-Fp2', '1-AF8', '1-AF4', '1-AFz', '1-Fz', '1-F2',	'1-F4',	'1-F6',	'1-F8',	...
    '1-FT8', '1-FC6', '1-FC4',	'1-FC2', '1-FCz', '1-Cz', '1-C2', '1-C4', ...
    '1-C6',	'1-T8',	'1-TP8', '1-CP6', '1-CP4', '1-CP2', '1-P2',	'1-P4', ...
    '1-P6',	'1-P8',	'1-P10', '1-PO8', '1-PO4', '1-O2', '1-FT9', '1-PO9', ...
    '1-FT10', '1-PO10', '1-HeRe', '1-HeLi', '1-VeUp', '1-VeDo', '1-EMG1a', ...
    '1-EMG1b', '1-EMG2a', '1-EMG2b', '1-EMG3a', '1-EMG3b',	'1-EMG4a', ...
    '1-EMG4b', '1-C17', '1-C18', '1-C19', '1-C20', '1-C21',	'1-C22', '1-C23', ...
    '1-C24', '1-C25', '1-C26', '1-C27',	'1-C28', '1-C29', '1-C30', '1-C31', ...
    '1-C32', '1-EXG1', '1-EXG2', '1-EXG3', '1-EXG4', ...
    '1-EXG5',	'1-EXG6', '1-EXG7',	'1-EXG8', 'Status'};

montage.labelnew = montage.labelorg;

tra = eye(105);

switch id
    % swap channels TP7 (16) and FT9 (65)
    case {'0118'}
        tra(16, 16)   = 0;
        tra(16, 65)  = 1;
        tra(65, 65) = 0;
        tra(65, 16)  = 1; 
    otherwise
        disp('No channel swapping');
end

montage.tra = tra;

end