function [ D ] = compi_reject_eyeblink_artefacts_for_eyeblink_correction( D, options )
% ------------------------------------------------------------------------- 
% COMPI_REJECT_EYEBLINK_ARTEFACTS_FOR_EYEBLINK_CORRECTION Detects and 
% rejects noisy trials. This function calls on a simple artefact detection 
% routine (channel thresholding) in SPM and rejects the trials that were 
% marked as bad (amplitude exceeding S.methods.settings.threshold). 
% Channels with a proportion of more than S.badchantresh bad trials are
% marked as bad channels.
%   IN:     D       - epoched EEG data set
%           options - the struct that holds all analysis options
%   OUT:    D       - epoched EEG data set with flags for bad trials
% 
% Based on dmpad_reject_eyeblink_artefacts_for_eyeblink_correction
% ------------------------------------------------------------------------- 


S.D = D;
S.mode = 'reject';
S.badchanthresh = options.eeg.preproc.artifact.badchanthresh;

S.methods.channels = {'EEG'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = options.eeg.preproc.artifact.badtrialthresh;
S.methods.settings.excwin = 1000;
% excision window: Window (in ms) to mark as bad around each jump 
% (for mark mode only), 0 - do not mark data as bad

S.append = 1; 
% 1: if other artefact detection has already been applied, 
% only the remaining clean channels will be used for this session.
% 0: all channels will be scanned for artefacts
S.prefix = 'a';

D = spm_eeg_artefact(S);

if ~options.eeg.preproc.keep
    delete(S.D);
end


end

