function fig = tayeeg_fig_options(options)
% -------------------------------------------------------------------------
% Function that ammends option structure with all options relevant to
% creation of figures.
% -------------------------------------------------------------------------


%% Analysis options
  
% display maximum intensity projection instead of slice section with peak pixel
fig.doMIP = true;

fig.StatsThreshold  = 'cluster'; % 'cluster', 'peak'
fig.displayedMap    = 'unthresholded'; % 'thresholdSPM', 'unthresholded'
fig.displayMode     = 'checkReg'; %'volumeviewer', 'surfacePlot'
fig.pCluster        = 0.05; % cluster correction p value threshold

% smoothes thresholded SPMs slightly for display reasons in CheckReg
% because of 1 voxel FWHM smooth, neighboring voxel will have half
% the value and shall be included in color map
switch fig.displayedMap
    case 'unthresholded'
        fig.doSmooth = false;
    case 'thresholdSPM'
        fig.doSmooth = true;
end

fig.doSave = true;

% Specify contrast type - F or T
fig.blobContrastType = 'F';

% Specify numner of contrast (for F-contrast number is 3)
fig.FContrastArray = [3];


fig.colmap = 'jet';
fig.linewidth = 4;
fig.linestyle = 'w-';
