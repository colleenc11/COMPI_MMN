function fh = compi_plot_source_waveforms_as_subplots(options)
% Function for plotting extracted mean (over voxels) ERP waves (beta waves)
%   - over all voxels of the most significant 2nd level cluster
%   - of each computational quantity
%   - for each subject
%
% OUT
%   fh       [1, nContrasts] figure handles
% See also dmpad_get_blobs_as_waveforms

if nargin < 1
    options = compi_mmn_options();
end

if ~exist(fullfile(options.roots.results_source, options.condition, 'figures'), 'dir')
    mkdir(fullfile(options.roots.results_source, options.condition, 'figures'));
end

%%  Load data for plotting

% specify significant sources
% 1: 'MSP_leftA1'; 2: 'MSP_rightA1', 3: 'MSP_leftSTG', 4: 'MSP_rightSTG',
% 5: 'MSP_leftIFG', 6: 'MSP_rightIFG'
sourceArray = {'1', '2', '3', '4', '5', '6'};
sourceNames = {'Left A1', 'Right A1', 'Left STG', 'Right STG', 'Left IFG', 'Right IFG'};

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
clusterMaskArray = {[100 100], [100 100], [100 100], [100 100], [100 100], [100 100]};
% colour of plot
% colourBlobArray = {'-m',  '-r', '-c',  '-g', '-b', '-y'};
colourBlobArray = {'-bl',  '-bl', '-bl',  '-bl', '-bl', '-bl'};

% loop over sources
for c = 1:length(sourceArray)
    hp = subplot(6,1,c);
    meanERPWave = mean(cell2mat(erpWave(:,c)),1).*10^2; % muV
    stdErrorERPWave = std(cell2mat(erpWave(:,c)),1).*10;
    clusterMask = clusterMaskArray{c};

    compi_plot_sourcewaveforms(options, meanERPWave, stdErrorERPWave, ...
     clusterMask,colourBlobArray{c});

    set(get(hp,'YLabel'),'String','\mu V','FontSize',20);
    set(hp,'LineWidth',2,'FontSize',8, 'FontName','Helvetica');
    ylim(yLimArray{c});
%     title(sourceNames{c});
    
end

% title(stringTitle);

imageFile = fullfile(options.roots.results_source, options.condition, 'figures', [options.condition '_source_results']);
saveas(gcf, imageFile, 'png');

end

