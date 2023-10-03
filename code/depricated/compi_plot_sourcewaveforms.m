function compi_plot_sourcewaveforms(options, meanERP, stdERP, colourBlob)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCEWAVEFORMS Function for plotting extracted mean (over
% voxels) ERP waves (beta waves) for individual source
%
%   IN:     options              as set by compi_set_analysis_options();
%           meanERP              averaged ERP
%           std ERP              standard deviation of ERP
%           colourBlob           colour of plot
%
% See also dmpad_plot_sourcewaveforms
%--------------------------------------------------------------------------
      

% calculate time window for plotting
time_resolution = 1000 / options.eeg.preproc.downsamplefreq; % in milliseconds
epochwin        = options.eeg.preproc.epochwin;
tWindow         = epochwin(1):time_resolution:epochwin(2);

% plot average ERP with errorbar
tnueeg_line_with_shaded_errorbar(tWindow, meanERP, stdERP, colourBlob,1);

end


