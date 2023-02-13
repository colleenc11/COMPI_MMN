function fh = compi_check_firstlevelmask( id, options )
% COMPI_CHECK_1STLEVEL_MASK Displays the 1st level mask.nii image and saves the plot for one subject
% of the COMPI study. 
%   IN:     id          - subject identifier string, e.g. '0101'
%           options     - the struct that holds all analysis options
%   OUT:    fh          - figure handle to the image

details = compi_get_subject_details(id, options);

spm_check_registration(fullfile(details.eeg.firstLevel.sensor.pathStats, 'mask.nii'));
title(details.eeg.subproname);

fh = gcf;
% saveas(fh, details.eeg.quality.firstlevelmask,'fig');

    
% diagnostics: save mask
if ~exist(fullfile(options.roots.diag_eeg, 'first_level_mask'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'first_level_mask'));
end

saveas(fh, fullfile(options.roots.diag_eeg, 'first_level_mask', ['first_level_mask_' id]), 'png');
close(gcf);
close all


end