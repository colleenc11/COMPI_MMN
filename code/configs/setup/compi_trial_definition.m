function [ trialdef ] = compi_trial_definition( options, details )
% -------------------------------------------------------------------------
% COMPI_TRIAL_DEFINTION Trial definition for COMPI  EEG data sets
%   IN:     options     - struct that holds all analysis options
%           details     - struct that holds subject-specific paths
%   OUT:    trialdef    - struct with labels, types and values of triggers
% -------------------------------------------------------------------------
switch options.eeg.preproc.trialdef
    case 'tone'
        trialdef.conditionlabel = {'tone', 'tone'};
        trialdef.eventtype  = repmat({'STATUS'}, [1 2]);
        trialdef.eventvalue = [1 2]; 
end

save(details.eeg.trialdefinition, 'trialdef');

end

