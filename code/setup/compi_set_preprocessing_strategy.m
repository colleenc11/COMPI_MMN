function preprocessing = compi_set_preprocessing_strategy(resultroot, ...
    preprocStrategyValueArray)

if nargin < 2 || isempty(preprocStrategyValueArray)
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

preprocessing             = [];

% Important: please append new strategy components to the END of the list
% and new strategy options to the END of the array

preprocessing.badTrialsThreshold              = {'80', '100', '75'};
preprocessing.eyeDetectionThreshold           = {'subject-specific', 'default'};
preprocessing.eyeCorrectionMethod             = {'SSP', 'Berg', 'reject','PSSP'};
preprocessing.eyeCorrectionComponentsNumber   = {'3', '1'};
preprocessing.downsample                      = {'no', 'yes'};
preprocessing.lowpass                         = {'45', '35', '30'};
preprocessing.baseline                        = {'0', '1'};
preprocessing.smoothing                       = {'no', 'yes'};
preprocessing.digitization                    = {'subject-specific', 'template'};
preprocessing.highpass                        = {'0.5', '0.1'};

% Preprocessing strategies
preprocessing.selectedStrategy.valueArray = preprocStrategyValueArray;
preprocessing.selectedStrategy.prefix     = ['preproc_strategy' ...
    sprintf('_%d',preprocessing.selectedStrategy.valueArray)];
preprocessing.root                         = fullfile(resultroot);

end