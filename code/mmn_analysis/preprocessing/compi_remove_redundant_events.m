function toneevents = compi_remove_redundant_events(D, trialdef, options)
%--------------------------------------------------------------------------
% Epochs continuous EEG data based on trial definition
%   IN:     D         - continuous EEG data set
%           options   - structure of options
%   OUT:    D         - epoched EEG data set
%--------------------------------------------------------------------------

%% Main

switch options.task.type
    case 'ioio'
        toneevents = {};
        
        for i = 1:length(D.events)
        
            event = D.events{1,i};
        
            if length(event) > 1
        
                for j = 1:length(event)
        
                    if event(j).value == trialdef.eventvalue
                        toneevents{i} = event(j);
                    end
                end
            else
                toneevents{i} = event;
            end
        end
    
    case 'mmn'
        toneevents = {};
        for i = 1:length(D.events)
            event = D.events{1,i};

            if length(event) > 1
                for j = 1:length(event)
                    if event(j).value == any(trialdef.eventvalue)
                        toneevents{i} = event(j);
                    end
                end
            else
                toneevents{i} = event;
            end
            
        end

end