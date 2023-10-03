function condlist = compi_oddball_conditions(factorNames, options)
%--------------------------------------------------------------------------
% Modify condition list based on subject-specific situations.
%   IN:     factorNames   - analysis-specific factor (e.g. oddball)
%           options       - structure of options
%   OUT:    condlist       - updated condition list
%--------------------------------------------------------------------------

%-- load oddball file ----------------------------------------------------%
switch factorNames
    case {'oddball_stable', 'oddball_volatile'}
        condlist = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones_phase.mat')), 'oddball_tones');
    case 'oddball'
        condlist = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones_weber.mat')), 'oddball_tones');
end


end