function compi_plot_sourcewaveforms(options, meanERP, stdERP, ...
    significantInterval,colourBlob)


% plots source waveforms for given ROIs
group       = options.condition;
      
% specify time window - needs to equal 141 (unsure of units)
% how to go from 176 (ms) to 141
tWindow     = options.eeg.stats.firstLevelAnalysisWindow(1):2.5:options.eeg.stats.firstLevelAnalysisWindow(2);
% tWindow = 100:1:240;


% Plot in each subplot the following:

% plot significant time window
widthSignificantInterval = diff(significantInterval);
hRect = rectangle('Position', [significantInterval(1), 0, ...
    widthSignificantInterval, 1]);
hold on;

% plot average ERP with errorbar
tnueeg_line_with_shaded_errorbar(tWindow, meanERP, stdERP, colourBlob,1);
% plot(tWindow,meanERP,'k','LineWidth',2);


yLimits = ylim;
heightSignificantInterval = diff(yLimits);
set(hRect, 'Position', [significantInterval(1), yLimits(1), ...
    widthSignificantInterval, heightSignificantInterval]);
set(hRect, 'FaceColor', 0.95*[1 1 1]);


% [firstVoxel,~,~, ~, ~] = compi_first_last_significant_time_clusterLevelsignificance(options,iContrast, group);

% dmpad_vline(firstVoxel,'r',num2str(firstVoxel));


