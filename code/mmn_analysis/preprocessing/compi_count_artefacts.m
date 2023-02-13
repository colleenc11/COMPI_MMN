function [] = compi_count_artefacts( D, details)
% COMPI_COUNT_ARTEFACTS Counts bad trials in an EEG data set
%   This function counts the number of bad trials in a preprocessed EEG
%   data set and saves this number into a subject-specific file in the
%   preprocessing folder for later use in computing artefact statistics.
%   IN:     D               - EEG data set after artefact rejection
%           details         - the struct that holds all paths and filenames
%   OUT:    numArtefacts    - number of bad trials in D
%           badChannels     - struct with number and names of bad channels in D

idxArtefacts = badtrials(D);
numArtefacts = numel(idxArtefacts);

numBadChannels = numel(badchannels(D));
badChannelNames = badchannels(D);

nGoodTrials = tnueeg_count_good_trials(D);
    
trialStats.numArtefacts = numArtefacts;
trialStats.idxArtefacts = idxArtefacts;
trialStats.numBadChannels = numBadChannels;
trialStats.badChannelNames = badChannelNames;
trialStats.nGoodTrials = nGoodTrials;

save(details.eeg.trialStats, 'trialStats');

end