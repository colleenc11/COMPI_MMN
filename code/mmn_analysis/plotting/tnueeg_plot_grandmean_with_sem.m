function mnCHR_plot_grandmean_with_sem(gaData, titleStr, condNames, saveName, lineColors, lineWidth)
% MNCHR_PLOT_GRANDMEAN_WITH_SEM Plots Grand Averages with shaded Error Bars
%   This function plots the grand averages and its standard errors of
%   the mean on the corresponding time axis for one or more conditions. It
%   plots the means of all conditions with their respective confidence
%   interval (1.96 * standard error of the mean) as patches around the mean
%   ERPs. Grand averages and SEMs have to be computed in advance.
%   Modified from TNUEEG_PLOT_GRANDMEAN_WITH_SEM
%   IN:     gaData      - CellArray of filenames pointing to previously
%                       calculated grand averages and their SEMs. One line
%                       (entry) per condition/session/line to be plotted.
%           titleStr    - Title string for the figure
%           condNames   - CellArray of condition/session/line names for the
%                       legend.
%           saveName    - Name and path of figure file to save the plot.
%           lineColors  - (nLines x 3) matrix of RGB colors for the lines.
%           lineWidth   - Line width for the lines.
%   OUT:    -


conlist = condNames;
numConditions = numel(conlist);

plotHandles = [];
h = figure; hold on;

% loop over all conditions present in the EEG files
for iCon = 1: numConditions
    conlabel = char(conlist{iCon});
    gas.(conlabel) = gaData.(conlabel);
    
    sem = gas.(conlabel).error;
    line = gas.(conlabel).mean;
    timeAxis = gas.(conlabel).time;
    sem = sem * 1.96; % 95% confidence interval
    H(iCon) = tnueeg_line_with_shaded_errorbar(timeAxis, line, sem, ...
        {'Color', lineColors(iCon, :), 'LineWidth', lineWidth}, 1);
    plotHandles = [plotHandles H(iCon).mainLine];
    
end    
%%%%%%%%%%%%%%%%%%%%%%%%

legend(plotHandles, condNames{:});
%ylim([-1.7 1.5]);
ylabel('Field intensity (in \muV)');
xlim([timeAxis(1) timeAxis(end)]);
xlabel('Time (ms after tone onset)');
grid on;

title(titleStr);

savefig(h, saveName);


end

