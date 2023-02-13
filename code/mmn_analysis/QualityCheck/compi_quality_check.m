function compi_quality_check(options)
%% ------------------------------------------------------------------------
%  Quality Check
% ------------------------------------------------------------------------

% Plot trial stats
compi_plot_trialstats(options);

% Plot eye-blink rates for all subjects
compi_plot_ebRate(5, options);

% Plot eye-blink rates for all subjects
% compi_mmn_plot_RTs_hits(options);

for idCell = options.subjects.IDs{2} %all
    id = char(idCell);

    % Plot eye-blinks before and after
    [fh1, fh2] = dmpad_plot_effects_of_eyeblink_correction_on_average_eyeblink( id, options );

    % Displays the 1st level mask.nii for each subject
%     compi_check_firstlevelmask( id, options )

end

% Overlap between standard/deviants and model regressors
[condTable, regOverlap] = compare_regressor_overlap(id, options);