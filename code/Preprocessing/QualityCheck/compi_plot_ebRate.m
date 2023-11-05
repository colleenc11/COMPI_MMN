function compi_plot_ebRate(options)
%--------------------------------------------------------------------------
% COMPI_PLOT_EBRATE Plot eye-blink per minute rate for each subject.
%   IN:     options:  the struct that contains all analysis options
%   OUT:    -
%--------------------------------------------------------------------------

% Eye-blinks per minute threshold
cut_off = 5;

% Collect eye-blink rates for each subject
for iSub = 1:length(options.subjects.all)
    id = options.subjects.all{iSub};

    details = compi_get_subject_details(id, options);

    cd(details.eeg.preproot);

    ebRun1 = load("EBperMin_Run.mat");
    ebRate.Run1(iSub) = ebRun1.num_eb_per_min;

end

% Write ouput table
ebRateTable = table(ebRate.Run1', ...
                        'RowNames', options.subjects.all', ...
                        'VariableNames', {'Run1', ...
                        });

save(fullfile(options.roots.diag_eeg, 'ebRateTable'), 'ebRateTable');

%% Plot Data

% Preperation - Run1
aboveCut1               = (ebRate.Run1>=cut_off);
bottomLine1             = ebRate.Run1;
topLine1                = ebRate.Run1;
bottomLine1(aboveCut1)  = NaN;
topLine1(~aboveCut1)    = NaN;

% Plot eye-blink rates
nSubjects = length(options.subjects.all);
x = 1:nSubjects;

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

sgtitle('Eye-blinks per minute');

saveas(gca, fullfile(options.roots.diag_eeg, ['ebRate_' num2str(cut_off)]),'fig');
saveas(gca, fullfile(options.roots.diag_eeg, ['ebRate_' num2str(cut_off)]),'png');

close all

cd(options.roots.results)
end 


