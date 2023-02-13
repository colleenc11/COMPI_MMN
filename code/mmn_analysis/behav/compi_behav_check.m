function compi_behav_check( options )
% compi_behav_check Collect behavioral summary in table and plot. 
%   IN:     optionally:
%           options         - the struct that contains all analysis options
%   OUT:    -

if ~exist(options.roots.results_behav, 'dir')
    mkdir(options.roots.results_behav);
end

% loop through subjects and collect trial numbers
for iSub = 1: length(options.subjects.all)
    subID = char(options.subjects.all{iSub});
    details = compi_get_subject_details(subID, options);

    load(details.files.behav_measures{1}, 'behav_measures');

    if iSub == 1
        behav_all = [behav_measures];
    else
        behav_all = [behav_all; behav_measures];
    end

end

% Set subject IDs as row names
behav_all.Properties.RowNames = options.subjects.all;

behavStatsTable = behav_all;

% Save beahvioral statistics in table
save(fullfile(options.roots.results_behav, 'behavStatsTable.mat'),'behavStatsTable');

%% Plot Trial Statistics

nSubjects = length(options.subjects.all);
x = 1:nSubjects;

% Plot Advice Taken
advice = 100*behav_all.AT_total;
figure;
plot(x, advice, 'r*');
ax = gca;
ax.YLim = [0, 100];
xlabel('Subjects'); ylabel('Advice Taken (%)');
title(['Subject Took Advice']);

saveas(gcf, fullfile(options.roots.results_behav, 'advice_taken'), 'png');

% Plot Helpful Advice Taken
advice = 100*behav_all.AT_acc;
figure;
plot(x, advice, 'r*');
ax = gca;
ax.YLim = [0, 100];
xlabel('Subjects'); ylabel('Helpful Advice Taken (%)');
title(['Advice Taken When Helpful']);

saveas(gcf, fullfile(options.roots.results_behav, 'helpful_advice_taken'), 'png');

close all
end
