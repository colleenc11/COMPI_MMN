function compi_quality_check(options)
%% ------------------------------------------------------------------------
%  COMPI_QUALITY_CHECK Perform quality check on preprocessed data.
%   IN:     options    - the struct that holds all analysis options
%   OUT:    --
% -------------------------------------------------------------------------

% Plot trial stats
compi_plot_trialstats(options);

% Plot eye-blink rates for all subjects
compi_plot_ebRate(options);

for idCell = options.subjects.all
    id = char(idCell);

    % Plot eye-blinks before and after
    [~] = compi_plot_effects_of_eyeblink_correction_on_average_eyeblink( id, options );

end

end