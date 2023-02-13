function oddball = compi_oddball_conditions(id, factorNames, options)
%--------------------------------------------------------------------------
% Modify condition list based on subject-specific situations.
%   IN:     phase     - specific phase type (stable, volatile, firstStable)
%           details   - subject-specific details
%           options   - structure of options
%   OUT:    phaselist - updated condition list
%--------------------------------------------------------------------------

%-- load oddball file ----------------------------------------------------%
switch factorNames
    case 'oddball_phases'
        oddball = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones_phase.mat')), 'oddball_tones');
    case 'oddball'
        oddball = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones_weber.mat')), 'oddball_tones');
end


end