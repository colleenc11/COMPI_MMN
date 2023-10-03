function condlist = compi_phase_conditions(D, options)

% Check if number of condition match
if length(D.events) == 170

    condlist = cell(1, length(D.events));

    switch options.eeg.erp.type
        case {'phase'}
            for i = 1: length(D.events)
                if i <= 34
                    condlist(i) = {'stable1'};
                elseif i >= 35 & i <= 136
                    condlist(i) = {'volatile'};
                else
                    condlist(i) = {'stable2'};
                end
            end
        case {'2bins'}
            for i = 1: length(D.events)
                if i <= 34
                    condlist(i) = {'stable'};
                elseif i >= 35 & i <= 136
                    condlist(i) = {'volatile'};
                else
                    condlist(i) = {'stable'};
                end
            end
    end

else
    disp('Number of events in data do not match paradigm.');

end

end