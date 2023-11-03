function compi_grandmean_plot_phase_erp(channel, options)
%--------------------------------------------------------------------------
% COMPI_GRANDMEAN_PLOT_PHASE_ERP Plots the grand averages of the difference
% waveform from the stable and volatile phase togehter with their SEM.
%   IN:     channel     - string with name of the channel
%           options     - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% Main

stabMMN = load(fullfile(options.roots.erp, options.condition, ...
    'oddball_stable', 'GA', [channel '_ga.mat']));

volMMN  = load(fullfile(options.roots.erp, options.condition, ...
    'oddball_volatile', 'GA', [channel '_ga.mat']));

ga.stableMMN = stabMMN.ga.diff;
ga.volMMN    = volMMN.ga.diff;
      
regressor = 'oddball_phase';

compi_grandmean_plot(ga, channel, regressor, options);