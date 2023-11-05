function condlist = compi_oddball_conditions(factorNames, options)
%--------------------------------------------------------------------------
% COMPI_ODDBALL_CONDITIONS Generates a list of conditions based on the 
% specified factor. Note: All subjects received the same auditory tone input.
%   IN:     factorNames   - analysis-specific factor (e.g. oddball)
%           options       - structure of options
%   OUT:    condlist       - updated condition list
%--------------------------------------------------------------------------

% Load the appropriate oddball file based on the factor name
switch factorNames
    case {'oddball_stable', 'oddball_volatile'}
        condlist = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones_phase.mat')), 'oddball_tones');
    case 'oddball'
        condlist = getfield(load(fullfile(options.roots.config,  ...
            'oddball_tones.mat')), 'oddball_tones');
end


end