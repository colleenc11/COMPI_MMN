function [ trialdef ] = compi_trial_definition( options, details )
%COMPI_TRIAL_DEFINTION Trial definition for COMPI  EEG data sets
%   IN:     options     - struct that holds all analysis options
%           paths       - struct that holds all general paths
%   OUT:    trialdef    - struct with labels, types and values of triggers

switch options.eeg.preproc.trialdef
    case 'ioio_outcome'
        trialdef.conditionlabel = {'outcome'};
        trialdef.eventtype  = {'STATUS'};
        trialdef.eventvalue = 4;
    case 'ioio_cue'
        trialdef.conditionlabel = {'cue'};
        trialdef.eventtype = {'STATUS'};
        trialdef.eventvalue = 2;
    case 'ioio_trial_begin'
        trialdef.conditionlabel = {'begin'};
        trialdef.eventtype = {'STATUS'};
        trialdef.eventvalue = 1;
    case 'tone'
        trialdef.conditionlabel = {'tone', 'tone'};
        trialdef.eventtype  = repmat({'STATUS'}, [1 2]);
        trialdef.eventvalue = [1 2]; 
end

save(details.eeg.trialdefinition, 'trialdef');

end

