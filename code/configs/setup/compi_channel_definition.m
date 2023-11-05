function [ chandef ] = compi_channel_definition( details )
% ------------------------------------------------------------------------- 
% COMPI_CHANNEL_DEFINTION Channel definition for COMPI EEG data sets
%   IN:     details     - struct that holds subject-specific paths
%   OUT:    chandef     - struct with as many fields as channel types
% ------------------------------------------------------------------------- 

chandef{1}.type = 'EOG';
chandef{1}.ind = [69 70 71 72];

save(details.eeg.channeldef, 'chandef');

end

