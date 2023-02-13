function compi_mmn_plot_RTs_hits(options)


if ~exist(fullfile(options.roots.diag_eeg, 'behav_stats'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'behav_stats'));
end

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

% Write ouput table
behavTable = table(averageRT', avgHitRate', averageMisses', averageErrors', avgPerformance',...
                        'RowNames', options.subjects.all', ...
                        'VariableNames', {'averageRT', 'avgHitRate', ...
                        'averageMisses', 'averageErrors', 'avgPerformance'});

save(fullfile(options.roots.diag_eeg, 'behav_stats', 'behavTable'), 'behavTable');

% Plot Errors
figure;
colors=winter(6);
e = notBoxPlot(averageErrors,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',[0 1 0]);
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('Number of Error');

saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_errors'),'fig');
saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_errors'), 'png');

% Plot Hit Rate
figure;
colors=winter(6);
e = notBoxPlot(avgHitRatePerc,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',[0 1 0]);
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('Hit Rate (%)');

saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_hitrate'),'fig');
saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_hitrate'), 'png');

% Plot Mean RT
figure;
colors=jet(numel(1));
e = notBoxPlot(averageRT,'markMedian',true);
set(e.data,'MarkerSize', 10);
set(e.data,'Marker','o');
set(e.data,'Color',colors(1,:));
set(e.sdPtch,'FaceColor',colors(1,:));
set(e.semPtch,'FaceColor',[0.9 0.9 0.9]);
set(gca,'FontName','Calibri','FontSize',40);
ylabel('RT (ms)');

saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_rt'),'fig');
saveas(gca, fullfile(options.roots.diag_eeg, 'behav_stats', 'behav_rt'), 'png');

end