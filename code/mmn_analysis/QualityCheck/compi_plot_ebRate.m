function compi_plot_ebRate(cut_off, options)
%--------------------------------------------------------------------------
% Plots eye-blink per minute rate for each subject.
%--------------------------------------------------------------------------

%% Collect Data

% Collect eye-blink rates for each subject
for iSub = 1:length(options.subjects.all)
    id = options.subjects.all{iSub};

    details = compi_get_subject_details(id, options);

    cd(details.eeg.preproot);

    switch options.task.type
        case 'ioio'

            ebRun1 = load("EBperMin_Run1.mat");
            ebRate.Run1(iSub) = ebRun1.num_eb_per_min;
        
            ebRun2 = load("EBperMin_Run2.mat");
            ebRate.Run2(iSub) = ebRun2.num_eb_per_min;

        case 'mmn'
            ebRun1 = load("EBperMin_Run.mat");
            ebRate.Run1(iSub) = ebRun1.num_eb_per_min;
    end

end

switch options.task.type
    case 'ioio'

        ebRate.AvgRate = (ebRate.Run1 + ebRate.Run2)/2;
        % Write ouput table
        ebRateTable = table(ebRate.Run1', ...
                                ebRate.Run2', ...
                                ebRate.AvgRate', ...
                                'RowNames', options.subjects.all', ...
                                'VariableNames', {'Run1', ...
                                'Run2', 'AvgRate'});

    case 'mmn'

        % Write ouput table
        ebRateTable = table(ebRate.Run1', ...
                                'RowNames', options.subjects.all', ...
                                'VariableNames', {'Run1', ...
                                });

end

save(fullfile(options.roots.diag_eeg, 'ebRateTable'), 'ebRateTable');

%% Plot Data

% Preperation - Run1
aboveCut1 = (ebRate.Run1>=cut_off);
bottomLine1 = ebRate.Run1;
topLine1 = ebRate.Run1;
bottomLine1(aboveCut1) = NaN;
topLine1(~aboveCut1) = NaN;

% % Preperation - Run2
% aboveCut2 = (ebRate.Run2>=cut_off);
% bottomLine2 = ebRate.Run2;
% topLine2 = ebRate.Run2;
% bottomLine2(aboveCut2) = NaN;
% topLine2(~aboveCut2) = NaN;
% 
% % Preperation - Run3
% aboveCut3 = (ebRate.AvgRate>=cut_off);
% bottomLine3 = ebRate.AvgRate;
% topLine3 = ebRate.AvgRate;
% bottomLine2(aboveCut3) = NaN;
% topLine3(~aboveCut3) = NaN;

%%% Plot eye-blink rates %%%
% tiledlayout(3,1)
nSubjects = length(options.subjects.all);
x = 1:nSubjects;

% Run 1
ax1 = nexttile;
plot(x, bottomLine1, 'r*', x, topLine1,'k*');
title(['Run 1']);
xlabel('Subjects'); ylabel('EB Rate (EB/min)');
legend(['Rate <= ' num2str(cut_off) ' EB/min'])

% Subjects crossing the lower threshold
subIdx = ebRate.Run1 < cut_off;
if ~isempty(subIdx)
    text(x(subIdx), ebRate.Run1(subIdx) -4, char(options.subjects.all{subIdx}), ...
    'horizontalAlignment', 'center', 'Color', 'black');
end
% 
% % Run 2
% ax2 = nexttile;
% plot(x, bottomLine2, 'r*', x, topLine2,'k*');
% title(['Run 2']);
% xlabel('Subjects'); ylabel('EB Rate (EB/min)');
% legend(['Rate <= ' num2str(cut_off) ' EB/min'])
% 
% % Subjects crossing the lower threshold
% subIdx = ebRate.Run2 < cut_off;
% if ~isempty(subIdx)
%     text(x(subIdx), ebRate.Run2(subIdx) -4, char(options.subjects.all{subIdx}), ...
%     'horizontalAlignment', 'center', 'Color', 'black');
% end
% 
% % Run 3
% ax3 = nexttile;
% plot(x, bottomLine3, 'r*', x, topLine3,'k*');
% title(['Avg Rate of Runs']);
% xlabel('Subjects'); ylabel('EB Rate (EB/min)');
% legend(['Rate <= ' num2str(cut_off) ' EB/min'])
% 
% % Subjects crossing the lower threshold
% subIdx = ebRate.AvgRate < cut_off;
% if ~isempty(subIdx)
%     text(x(subIdx), ebRate.AvgRate(subIdx) -4, char(options.subjects.all{subIdx}), ...
%     'horizontalAlignment', 'center', 'Color', 'black');
% end


ax1.YLim = [0 40];
%linkaxes([ax1 ax2 ax3], 'xy')
%set(gcf,'Position',[100 100 900 700])

sgtitle('Eye-blinks per minute');

saveas(gca, fullfile(options.roots.diag_eeg, ['ebRate_' num2str(cut_off)]),'fig');
saveas(gca, fullfile(options.roots.diag_eeg, ['ebRate_' num2str(cut_off)]),'png');

close all

cd(options.roots.results)
end 


