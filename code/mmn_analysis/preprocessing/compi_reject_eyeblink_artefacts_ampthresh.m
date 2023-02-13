function [ D ] = compi_reject_eyeblink_artefacts_ampthresh( D, options )
% compi_reject_eyeblink_artefacts_ampthresh
%   Detects and rejects any epochs containing transients which exceed 
%   500 µV are excluded from the eyeblink epoched data.
%   This function calls on a simple artefact detection routine (channel
%   thresholding) in SPM and rejects the trials that were marked as bad
%   (amplitude exceeding S.methods.settings.threshold).
%   Channels with a proportion of more than S.badchantresh bad trials are
%   marked as bad channels.
%   IN:     D       - epoched EEG data set
%           options - the struct that holds all analysis options
%   OUT:    D       - epoched EEG data set with flags for bad trials


S = [];
S.D = D;
S.mode = 'reject';

S.methods.channels = {'EEG'};
S.methods.fun = 'ampthresh';
S.methods.settings.threshold = 500; % EOG amplitude in uV
S.methods.settings.excwin = 1000;
% excision window: Window (in ms) to mark as bad around each jump 
% (for mark mode only), 0 - do not mark data as bad

S.append = 1; 
% 1: if other artefact detection has already been applied, 
% only the remaining clean channels will be used for this session.
% 0: all channels will be scanned for artefacts
S.prefix = 'b';

D = tnueeg_spm_eeg_artefact(S);

if ~options.eeg.preproc.keep
    delete(S.D);
end


end
