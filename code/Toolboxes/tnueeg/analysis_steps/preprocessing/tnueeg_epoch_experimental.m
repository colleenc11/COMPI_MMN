function [ D ] = tnueeg_epoch_experimental( D, trialdef, options )
%TNUEEG_EPOCH_EXPERIMENTAL Cuts a continuous EEG dataset into epochs
%according to a trial definition
%   IN:     D           - continuous EEG data set with trigger events
%           trialdef    - struct containing the labels (condition names),
%                       types and values of triggers that shall be used 
%                       for epoching.
%           options     - the struct that holds all analysis options
%   OUT:    D           - epoched EEG data set according to trial def.

S = [];
S.D = D;
isNumericValues = isnumeric(trialdef.eventvalue);

for i = 1: length(trialdef.eventvalue)
    S.trialdef(i).conditionlabel = trialdef.conditionlabel{i};
    S.trialdef(i).eventtype = trialdef.eventtype{i};
    if isNumericValues
        S.trialdef(i).eventvalue = trialdef.eventvalue(i);
    else
        S.trialdef(i).eventvalue = trialdef.eventvalue{i};
    end
    S.trialdef(i).trlshift = 0;
end

S.timewin = options.eeg.preproc.epochwin; 
S.bc = options.eeg.preproc.baselinecorrection;
S.prefix = 'e';
S.eventpadding = 0;

D = spm_eeg_epochs(S);

if ~options.eeg.preproc.keep
    delete(S.D);
end

end
