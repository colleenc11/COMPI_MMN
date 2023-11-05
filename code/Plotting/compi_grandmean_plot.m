function compi_grandmean_plot(ga, chanName, regressor, options)
%--------------------------------------------------------------------------
% COMPI_GRANDMEAN_PLOT Plots the grand averages of several conditions 
% togehter with their SEM.
%   IN:     ga          - variable with GA and SEM data for all conditions
%           chanName    - string with name of the channel
%           regressor   - string with name of the regressor
%           options     - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

%% Main

cols = compi_define_colors;

lineColors  = [cols.darkgray; cols.lightred; cols.lightgreen];
lineWidth   = 2;
titleStr    = [regressor ' ERPs at ' chanName ' in ' options.condition];

% get condition names
switch regressor
    case {'oddball'}
        condNames = {'standard', 'deviant', 'diff'};             
    case {'oddball_stable'}
        condNames = {'standStab', 'devStab', 'diff'}; 
    case {'oddball_volatile'}
        condNames = {'standVol', 'devVol', 'diff'};
    case {'oddball_phase'}
        condNames = {'stableMMN', 'volMMN'}; 
    otherwise
        condNames = {'low', 'high', 'diff'};             
end

% make sure we have a results directory
figRoot = fullfile(options.roots.erp, options.condition, regressor, 'Figures');
if ~exist(figRoot, 'dir')
    mkdir(figRoot);
end

% output file name
outputFig = fullfile(figRoot, ['ga_sem_' chanName '.fig']);

% Call plot function
compi_plot_grandmean_with_sem(ga, titleStr, condNames, outputFig, lineColors, lineWidth);

end

