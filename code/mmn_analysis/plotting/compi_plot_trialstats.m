function compi_plot_trialstats( options )
%--------------------------------------------------------------------------
% COMPI_PLOT_TRIALSTATS Performs quality checks for trial statistics.
%   IN:     options      - the struct that contains all analysis options
%   OUT:    -
%--------------------------------------------------------------------------
if nargin < 1
    options = compi_mmn_options;
end

% Create directory if it doesn't exist
if ~exist(options.roots.diag_eeg, 'dir')
    mkdir(options.roots.diag_eeg);
end

% Loop through subjects and collect trial numbers
for iSub = 1: length(options.subjects.all)
    subID = char(options.subjects.all{iSub});
    details = compi_get_subject_details(subID, options); 

    % Load trial statistics and eye blink rejection stats
    load(details.eeg.trialStats); 
    load(details.eeg.eyeblinkrejectstats)

    D               = spm_eeg_load(details.eeg.prepfile);
    nInitial        = length(D.events);

    % Collect trial stats based on eye correction method
    switch options.eeg.preproc.eyeCorrMethod
        case 'reject'
            nEyeblinktrials             = numel(trialStats.idxEyeartefacts.tone);
            nEyeartefactsTone(iSub)     = trialStats.numEyeartefacts.tone;
            nTrialsInitial(iSub)        = nInitial + nEyeblinktrials;
        case {'SSP', 'PSSP'}
            nTrialsInitial(iSub)        = nInitial;
            nEyeartefactsTone(iSub)     = ebstats.numEyeblinks;
            nEyeblinks(iSub)            = 0;
    end

    % Gather other trial statistics
    nArtefacts(iSub)       = trialStats.numArtefacts;
    nBadChannels(iSub)     = trialStats.numBadChannels;
    nGoodTrialsTone(iSub)  = trialStats.nGoodTrials.tone;

end

%% Plot Trial Statistics based on the eye correction method

switch options.eeg.preproc.eyeCorrMethod
    case 'reject'
        % table
        trialStatsTable = table(nTrialsInitial', ...
            nEyeblinks', ...
            nEyeartefactsTone',...
            nArtefacts', nBadChannels', ...
            nGoodTrialsTone', ...
            'RowNames', options.subjects.all', ...
            'VariableNames', {'nTrialsInitial', ...
            'nEyeblinks', ...
            'nEyeartefactsTone',...
            'nAdditionalArtefacts', 'nBadChannels', ...
            'nGoodTrialsTone'});
        % plot
        fh = mmn_plot_overview_trial_statistics(options.subjectIDs, nTrialsInitial, ...
            nEyeblinks, nArtefacts, nBadChannels, nGoodTrialsTone, nEyeartefactsTone);
        
    case {'SSP', 'PSSP'}
        % table
        trialStatsTable = table(nTrialsInitial', ...
            nEyeartefactsTone',...
            nArtefacts', nBadChannels', ...
            nGoodTrialsTone', ...
            'RowNames', options.subjects.all', ...
            'VariableNames', {'nTrialsInitial', ...
            'nEyeartefactsTone', ...
            'nAdditionalArtefacts', 'nBadChannels', ...
            'nGoodTrialsTone'});
        % plot
        fh = mmn_plot_overview_trial_statistics(options.subjects.all, nTrialsInitial, ...
            nEyeartefactsTone, nArtefacts, nBadChannels, nGoodTrialsTone);
        
end

% Save the table and plot
save(fullfile(options.roots.diag_eeg, 'trialStatsTable.mat'),'trialStatsTable');
saveas(fh, fullfile(options.roots.diag_eeg, 'trialStats'), 'png');

close all
end
