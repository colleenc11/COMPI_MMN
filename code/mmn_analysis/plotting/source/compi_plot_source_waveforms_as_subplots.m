function compi_plot_source_waveforms_as_subplots(factor, options)
%--------------------------------------------------------------------------
% COMPI_PLOT_SOURCEWAVEFORMS_AS_SUBPLOTS Function for plotting extracted 
% mean (over voxels) ERP waves (beta waves) over all voxels for each source
%
%   IN:     factor      a string with the name of the factor of interest
%           options     as set by compi_mmn_options();
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
erpWave     = compi_get_sourcewaveforms_all_subjects(factor, sourceArray, options);

%% loop over contrast, plot mean +- std error ERPs

fh          = figure;
stringTitle = ['Mean source waveform (over trials) for ' factor];
set(gcf, 'Name', stringTitle);

% loop over sources
for iSource = 1:length(sourceArray)
    hp = subplot(length(sourceArray),1,iSource);
    meanERPWave = mean(cell2mat(erpWave(:,iSource)),1); % muV
    stdErrorERPWave = std(cell2mat(erpWave(:,iSource)),1)./sqrt(length(options.subjects.all));

    % calculate time window for plotting
    time_resolution = 1000 / options.eeg.preproc.downsamplefreq; % in milliseconds
    epochwin        = options.eeg.preproc.epochwin;
    tWindow         = epochwin(1):time_resolution:epochwin(2);
    
    % plot sourcewave form 
    tnueeg_line_with_shaded_errorbar(tWindow, meanERPWave, stdErrorERPWave, '-b');

    % plot mean ERP waveform
    % plot(tWindow, meanERPWave, 'LineWidth', 2);

    set(get(hp,'YLabel'),'String','\mu V','FontSize',40);
    set(hp,'LineWidth',2,'FontSize',16, 'FontName','Helvetica');
    xlim([0 400])
    
    box(hp, 'off');

end


imageFile = fullfile(options.roots.results_source, options.condition, 'figures', [options.condition '_source_results_' factor]);
saveas(gcf, imageFile, 'fig');
saveas(gcf, imageFile, 'png');

close all;

end

