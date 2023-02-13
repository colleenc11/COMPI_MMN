function compi_create_montage_matrix(id, details, options);


if ~exist(fullfile(options.roots.diag_eeg, 'montage_matrix'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'montage_matrix'));
end
load(details.eeg.montage);

montageMatrix = montage.tra;
fh = figure; imagesc(montageMatrix); colorbar; title('Montage Matrix for COMPI IOIO EEG');
xlabel('Old channels'); ylabel('New channels');
saveas(fh, details.eeg.montagefigure,'fig');
saveas(fh, fullfile(options.roots.diag_eeg, 'montage_matrix', [id '_montage']),'png');
close(fh);

end