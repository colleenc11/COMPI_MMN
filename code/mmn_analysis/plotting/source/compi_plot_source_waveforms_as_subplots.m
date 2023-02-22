function compi_plot_source_waveforms_as_subplots(options)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCEWAVEFORMS_AS_SUBPLOTS Function for plotting extracted 
% mean (over voxels) ERP waves (beta waves) over all voxels for each source
%
%   IN:     options     as set by compi_set_analysis_options();
%
% See also dmpad_plot_source_waveforms_as_subplots and 
% dmpad_get_blobs_as_waveforms
%--------------------------------------------------------------------------

if nargin < 1
    options = compi_mmn_options();
end

if ~exist(fullfile(options.roots.results_source, options.condition, 'figures'), 'dir')
    mkdir(fullfile(options.roots.results_source, options.condition, 'figures'));
end


%% Get source waveforms

sourceArray = options.eeg.source.labels;
erpWave   = compi_get_sourcewaveforms_all_subjects(options, sourceArray);

%% loop over contrast, plot mean +- std error ERPs

fh = figure;
stringTitle = 'Mean source waveform (over trials) for computational quantities';
set(gcf, 'Name', stringTitle);

yLimArray = {
 1*[-1 1]
 1*[-1 1]
 1*[-1 1]
 1*[-1 1]
 1*[-1 1]
 1*[-1 1]
};

% significant time winow for plotting window around
clusterMaskArray = {[-100 -100], [-100 -100], [-100 -100], [-100 -100], [-100 -100], [-100 -100]};
% colour of plot
% colourBlobArray = {'-m',  '-r', '-c',  '-g', '-b', '-y'};
colourBlobArray = {'-bl',  '-bl', '-bl',  '-bl', '-bl', '-bl'};

% loop over sources
for iSource = 1:length(sourceArray)
    hp = subplot(length(sourceArray),1,iSource);
    meanERPWave = mean(cell2mat(erpWave(:,iSource)),1).*10^2; % muV
    stdErrorERPWave = std(cell2mat(erpWave(:,iSource)),1).*10;
    clusterMask = clusterMaskArray{iSource};

    compi_plot_sourcewaveforms(options, meanERPWave, stdErrorERPWave, ...
     clusterMask, colourBlobArray{iSource});

    set(get(hp,'YLabel'),'String','\mu V','FontSize',20);
    set(hp,'LineWidth',2,'FontSize',8, 'FontName','Helvetica');
    ylim(yLimArray{iSource});
    xlim([-100 450])
    
end

% title(stringTitle);

imageFile = fullfile(options.roots.results_source, options.condition, 'figures', [options.condition '_source_results']);
saveas(gcf, imageFile, 'png');

close all;

end

