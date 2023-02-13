function compi_grandmean_plot(ga, chanName, regressor, options, flag)
%--------------------------------------------------------------------------
% Plots the grand averages of several conditions togehter with their SEM.
%   IN:     ga          - variable with GA and SEM data for all conditions
%           chanName    - string with name of the channel
%           regressor   - string with name of the regressor
%           options     - the struct that holds all analysis options
%   OUT:    --
%--------------------------------------------------------------------------

% if nargin < 4
%     flag = '';
% end
% 
% if nargin < 3
%     options = mnCHR_set_analysis_options;
% end

%% Main

cols = compi_define_colors;

switch flag
    case 'groupdiff'
        
        % Gather plotting info
        switch options.eeg.erp.type
            case {'phase', '2bins'}
                titleStr = [regressor ' ERPs at ' chanName];
            otherwise
                titleStr = [regressor ' difference waves at ' chanName];
        end

        condNames = options.subjects.group_labels;
        lineColors = [cols.darkgray; cols.lightred; cols.blue];

        lineWidth = 2;

        % make sure we have a results directory
        FIGroot = fullfile(options.roots.erp, 'groupdiff', regressor, 'Figures');
        if ~exist(FIGroot, 'dir')
            mkdir(FIGroot);
        end

        saveName = fullfile(FIGroot, ['ga_sem_' chanName '.fig']);

    case 'groupdiff_stable'
        
        titleStr = [regressor ' stable difference waves at ' chanName];
        condNames = options.subjects.group_labels;
        lineColors = [cols.darkgray; cols.lightred; cols.blue];
        lineWidth = 2;

        % make sure we have a results directory
        FIGroot = fullfile(options.roots.erp, 'groupdiff', regressor, 'Figures');
        if ~exist(FIGroot, 'dir')
            mkdir(FIGroot);
        end

        saveName = fullfile(FIGroot, ['ga_sem_' chanName '_stable.fig']);
   
    case 'groupdiff_volatile'
        
        titleStr = [regressor ' volatile difference waves at ' chanName];
        condNames = options.subjects.group_labels;
        lineColors = [cols.darkgray; cols.lightred; cols.blue];
        lineWidth = 2;

        % make sure we have a results directory
        FIGroot = fullfile(options.roots.erp, 'groupdiff', regressor, 'Figures');
        if ~exist(FIGroot, 'dir')
            mkdir(FIGroot);
        end

        saveName = fullfile(FIGroot, ['ga_sem_' chanName '_volatile.fig']);
    otherwise

        switch regressor
            case {'oddball'}
                condNames = {'standard', 'deviant', 'diff'};
                lineColors = [cols.darkgray; cols.lightred; cols.lightgreen];
                lineWidth = 2;
                titleStr = [options.eeg.erp.type ' ' regressor ' ERPs at ' chanName ' in ' options.condition];
            
            case {'oddball_phases'}
                condNames = {'StabMMN', 'VolMMN'};
                lineColors = [cols.darkgray; cols.lightred];
                lineWidth = 2;
                titleStr = ['Phases oddball MMN at ' chanName ' in ' options.condition];

            case {'phase'}
                condNames = {'stable1', 'volatile', 'stable2'};
                lineColors = [cols.magenta; cols.cyan; cols.lightgreen];
                lineWidth = 2; 
                titleStr = [regressor ' ERPs at ' chanName ' in ' options.condition];             
            
            otherwise
                condNames = {'low', 'high', 'diff'};
                lineColors = [cols.darkgray; cols.lightred; cols.lightgreen];
                lineWidth = 2;
                titleStr = [regressor ' ERPs at ' chanName ' in ' options.condition];             
        end

        % make sure we have a results directory
        FIGroot = fullfile(options.roots.erp, options.condition, regressor, 'Figures');
        if ~exist(FIGroot, 'dir')
            mkdir(FIGroot);
        end

        saveName = fullfile(FIGroot, ['ga_sem_' chanName '.fig']);
    
end

% Call tnueeg plot function
compi_plot_grandmean_with_sem(ga, titleStr, condNames, saveName, lineColors, lineWidth);

