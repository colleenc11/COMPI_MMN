function conditions = compi_erp_lowhighPE_conditions(peValues, label, options)
% -------------------------------------------------------------------------
% COMPI_ERP_LOWHIGHPE_CONDITIONS Specifies trial type for each tone in a 
% sequence based on the 'low' or 'high' definition
%   IN:     peValues    - a vector of numbers indicating trialwise pwPE
%           label       - string indicating type of pwPE (epsi2 or epsi3)
%           options     - the struct that holds all analysis options
%   OUT:    conditions  - a cell array of condition labels of length nTones
%
%   Definitions:
%   Low PE trials       - lowest (options.eeg.erp.percentPe)% of pwPE values
%   High PE trials      - highest (options.eeg.erp.percentPe)% of pwPE values
%   Other trials        - all other tones in the sequence
% -------------------------------------------------------------------------

% Initialize
nValues = length(peValues);
conditions = repmat({'other'}, 1, nValues);

% Calculate the number of low and high PE trials
nLow    = round(options.eeg.erp.percentPe/100 *nValues);
nHigh   = nLow -1;

% Sort the PE values and determine indices for low and high values
[sortedPE, sortIdx] = sort(peValues);
lowIdcs             = sortIdx(1: nLow);
highIdcs            = sortIdx(end-nHigh: end);

% Label the conditions based on indices
conditions(lowIdcs)    = {'low'};
conditions(highIdcs)   = {'high'};

% Plotting
lowValues   = sortedPE(1: nLow);
highValues  = sortedPE(end-nHigh: end);

figure; 
plot(peValues, '.k'); hold on;
plot([1 nValues], [max(lowValues) max(lowValues)], '-g');
plot([1 nValues], [min(highValues) min(highValues)], '-r');

legend('All PE values', ['Lowest ' num2str(options.eeg.erp.percentPe) '%'],...
                        ['Highest ' num2str(options.eeg.erp.percentPe) '%']);
title(['Low and high ' label ' values']);     

end