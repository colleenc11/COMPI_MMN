function compi_create_montage_matrix(id, details, options)
% ------------------------------------------------------------------------- 
% COMPI_CREATE_MONTAGE_MATRIX Creates and visualizes the montage matrix and
% saves the visualization as both a FIG and PNG file.
%   IN: id      - subject identifier string, e.g. '0101'
%       details - subject-specific details struct
%       options - the struct that contains all analysis options
% ------------------------------------------------------------------------- 

% Ensure the directory for storing montage matrices exists
if ~exist(fullfile(options.roots.diag_eeg, 'montage_matrix'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'montage_matrix'));
end

% Load the montage data
load(details.eeg.montage);

% Extract the montage transformation matrix
montageMatrix = montage.tra;

% Plot the montage matrix
fh = figure; 
imagesc(montageMatrix); 
colorbar; 
title('Montage Matrix for COMPI EEG');
xlabel('Old channels'); 
ylabel('New channels');

% Save the figure in both FIG and PNG formats
saveas(fh, details.eeg.montagefigure,'fig');
saveas(fh, fullfile(options.roots.diag_eeg, 'montage_matrix', [id '_montage']),'png');
close(fh);

end