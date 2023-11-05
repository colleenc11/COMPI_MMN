function compi_mmn_plot_behavior(options)
% -------------------------------------------------------------------------
% COMPI_MMN_PLOT_BEHAVIOR Plot behavioral data from visual distraction
% task and calculate reaction time, errors and hit rate. 
%   IN:     options     as set by compi_mmn_options();
% -------------------------------------------------------------------------

% Settings
totalTrials     = 90; % total number of visual trials

% Initialize result variables
avgPerformance  = zeros(1, length(options.subjects.all));
averageRT       = zeros(1, length(options.subjects.all));
averageErrors   = zeros(1, length(options.subjects.all));
averageMisses   = zeros(1, length(options.subjects.all));

% Loop through each subject
for iSub = 1:length(options.subjects.all)
    id = options.subjects.all{iSub};

    % Get subject details
    details = compi_get_subject_details(id, options);

    % Load behavioral data
    load(details.files.behav_eeg);

    % Calculate performance metrics
    [ performance, meanRT, errors, misses ] = compi_calculate_visTask_performance( MMN );

    % Store calculated metrics for each subject
    avgPerformance(iSub) = performance;
    averageRT(iSub) = meanRT;
    averageErrors(iSub) = errors;
    averageMisses(iSub) = misses;
    
end

% Calculate Hit Rate
avgHit = (totalTrials - averageMisses);
avgHitRate = avgHit / totalTrials;
avgHitRatePerc = avgHitRate*100;

% Calculate Hit Rate Accuracy
faults = averageMisses + averageErrors;
avgCorrect = (totalTrials - faults);
percCorrect = avgCorrect / totalTrials;

% Write ouput table
visual_task_behavTable = table(averageRT', avgHitRate', percCorrect', averageMisses', averageErrors', avgPerformance',...
                        'RowNames', options.subjects.all', ...
                        'VariableNames', {'averageRT', 'avgHitRate', 'perc_avgHitRate',...
                        'averageMisses', 'averageErrors', 'avgPerformance'});

% Save table
save(fullfile(options.roots.behav, 'visual_task_behavTable.mat'),'visual_task_behavTable');

% Plot Errors
fh1 = figure;
colors=winter(6);
e = notBoxPlot(averageErrors,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',[0 1 0]);
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('Number of Error');

saveas(fh1, fullfile(options.roots.behav, 'errors'), 'fig');

% Plot Hit Rate
fh2 = figure;
colors=winter(6);
e = notBoxPlot(avgHitRatePerc,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',[0 1 0]);
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('Hit Rate (%)');

saveas(fh2, fullfile(options.roots.behav, 'hitRate'), 'fig');

% Plot Mean RT
fh3 = figure;
colors=jet(numel(1));
e = notBoxPlot(averageRT,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',colors(1,:));
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('RT (ms)');

saveas(fh3, fullfile(options.roots.behav, 'reactionTime'), 'fig');

close all;

end


