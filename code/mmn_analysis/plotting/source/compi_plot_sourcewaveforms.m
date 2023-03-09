function compi_plot_sourcewaveforms(options, meanERP, stdERP, ...
    significantInterval, colourBlob)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCEWAVEFORMS Function for plotting extracted mean (over
% voxels) ERP waves (beta waves) for individual source
%
%   IN:     options              as set by compi_set_analysis_options();
%           meanERP              averaged ERP
%           std ERP              standard deviation of ERP
%           significantInterval  signiticant stats time window for source
%           colourBlob           colour of plot
%
% See also dmpad_plot_sourcewaveforms
%--------------------------------------------------------------------------
      
% NOTE: this may need to change based on data
% TO DO: AUTOMOATE
tWindow     = options.eeg.preproc.epochwin(1):3.91:options.eeg.preproc.epochwin(2);

% Plot in each subplot the following:
% plot significant time window
widthSignificantInterval = diff(significantInterval);
hRect = rectangle('Position', [significantInterval(1), 0, ...
    widthSignificantInterval, 1]);
hold on;

% plot average ERP with errorbar
tnueeg_line_with_shaded_errorbar(tWindow, meanERP, stdERP, colourBlob,1);


yLimits = ylim;
heightSignificantInterval = diff(yLimits);
set(hRect, 'Position', [significantInterval(1), yLimits(1), ...
    widthSignificantInterval, heightSignificantInterval]);
set(hRect, 'FaceColor', 0.95*[1 1 1]);


