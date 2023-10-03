function compi_mmn_plot_behavior(options)
% -------------------------------------------------------------------------
% COMPI_MMN_PLOT_BEHAVIOR Plot behavioral data from visual distraction
% task and calculate reaction time, errors and hit rate. 
%   IN:     options     as set by compi_mmn_options();
% -------------------------------------------------------------------------

for iSub = 1:length(options.subjects.all)
    id = options.subjects.all{iSub};

    details = compi_get_subject_details(id, options);

    % load in behavioral data
    load(details.files.behav_eeg);

    [ ~, performance, meanRT, errors, misses ] = mmn_calculate_performance( MMN );
    
    avgPerformance(iSub) = performance;
    averageRT(iSub) = meanRT;
    averageErrors(iSub) = errors;
    averageMisses(iSub) = misses;
    
end

% Calculate Hit Rate
avgHit = (90 - averageMisses);
avgHitRate = avgHit / 90;
avgHitRatePerc = avgHitRate*100;

% Calculate Hit Rate Accuracy
faults = averageMisses + averageErrors;
avgCorrect = (90 - faults);
percCorrect = avgCorrect / 90;

% Write ouput table
visual_task_behavTable = table(averageRT', avgHitRate', percCorrect', averageMisses', averageErrors', avgPerformance',...
                        'RowNames', options.subjects.all', ...
                        'VariableNames', {'averageRT', 'avgHitRate', 'perc_avgHitRate',...
                        'averageMisses', 'averageErrors', 'avgPerformance'});

% Save table
save(fullfile(options.roots.results_behav, 'visual_task_behavTable.mat'),'visual_task_behavTable');

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

saveas(fh1, fullfile(options.roots.results_behav, 'behav_errors'), 'fig');

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

saveas(fh2, fullfile(options.roots.results_behav, 'behav_hitRate'), 'fig');

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

saveas(fh3, fullfile(options.roots.results_behav, 'behav_reactionTime'), 'fig');

close all;

end


