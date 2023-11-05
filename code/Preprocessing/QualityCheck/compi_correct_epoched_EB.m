function [ D ] = compi_correct_epoched_EB( D, details, options )
% -------------------------------------------------------------------------
% COMPI_CORRECT_EPOCHED_EB Applies the EB correction method used during 
% preprocessing to the EEG data set wich was epoched to the onset of all 
% detected eye blinks. Can be used to examine the effects of the correction
% on the average eyeblink.
%   IN:     D           - the EEG data set epoched to the onsets of EBs
%           details     - the struct that holds all subject-specific paths and files
%           options     - the struct that holds all analysis options
%   OUT:    D           - the corrected EEG data set epoched to the onsets of EBs
% 
% Adapted from DMPAD toolbox.
% -------------------------------------------------------------------------

%-- fetch EB correction matrix -------------------------------------------%
Dprep = spm_eeg_load(details.eeg.prepfile);

% get the inverted confounds matrix that was used in the correction of the 
% EEG data
SRC = tnueeg_bergscherg_source_waveforms(Dprep, options.eeg.preproc.eyeCorrMethod);
confoundsMatrix = SRC.invertedMatrix;

%-- preparation for montage step -----------------------------------------%
% adopt bad channels from preprocessing
if ~isempty(badchannels(Dprep))
    D = badchannels(D, badchannels(Dprep), 1);
    save(D);
end

label = D.chanlabels(indchantype(D, 'EEG', 'GOOD'))';

montage = [];
montage.labelorg = label;
montage.labelnew = label;

% configure the montage matrix to substract eye-related activity
montage.tra = eye(size(SRC.A, 1)) - SRC.A*confoundsMatrix;

%-- montage step ---------------------------------------------------------%
Dorig = D;

S1   = [];
S1.D = D;
S1.montage = montage;
S1.keepothers = true;
S1.updatehistory  = false;

D = spm_eeg_montage(S1); 

if isfield(Dorig,'inv')
    D.inv = Dorig.inv;
end

%-- clean up -------------------------------------------------------------%
Dcorr = D;

% change the channel order to the original order
tra = eye(D.nchannels);
montage = [];
montage.labelorg = D.chanlabels';
montage.labelnew = Dorig.chanlabels';

montage.chantypeorg  = lower(D.chantype)';
montage.chantypenew  = lower(Dorig.chantype)';

[~, sel2]  = spm_match_str(montage.labelnew, montage.labelorg);
montage.tra = tra(sel2, :);


S2   = [];
S2.D = D;
S2.montage = montage;
S2.keepothers = true;
S2.updatehistory  = 0;

D = spm_eeg_montage(S2);
delete(Dcorr);

% restore bad channels
if ~isempty(badchannels(Dorig))
    D = badchannels(D, badchannels(Dorig), 1);
end

% update history
D = D.history(mfilename, S1);
save(D);

D = move(D, details.eeg.quality.epoched_EB_corrected);

end

