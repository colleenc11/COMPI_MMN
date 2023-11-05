function preprocessing = compi_set_preprocessing_strategy(resultroot, ...
    preprocStrategyValueArray)
% -------------------------------------------------------------------------
% COMPI_SET_PREPROCESSING_STRATEGY Sets preprocessing parameters based on 
% a given strategy. This function defines various preprocessing strategies 
% for EEG data. If no specific strategy is provided, a default strategy is used.
%  IN:  resultroot                - Root directory for saving the results.
%       preprocStrategyValueArray - Array indicating the preprocessing 
%                                   strategy to be used (optional)
%  OUT: preprocessing             - Struct containing all selected 
%                                   preprocessing options.
% -------------------------------------------------------------------------

% Use default preprocessing strategy if none is provided
if nargin < 2 || isempty(preprocStrategyValueArray)
    preprocStrategyValueArray = [2 1 4 2 1 1 1 1 2];
end

preprocessing             = [];

% Define preprocessing options for various components of preproc pipeline.
% Important: When adding new strategy components, append them to the END 
% of the list.
% Similarly, when adding new options for a strategy, append them to the END
% of the array.

preprocessing.badTrialsThreshold              = {'80', '100', '75'};
preprocessing.eyeDetectionThreshold           = {'subject-specific', 'default'};
preprocessing.eyeCorrectionMethod             = {'SSP', 'Berg', 'reject','PSSP'};
preprocessing.eyeCorrectionComponentsNumber   = {'3', '1', '2'};
preprocessing.downsample                      = {'no', 'yes'};
preprocessing.lowpass                         = {'45', '35', '30'};
preprocessing.baseline                        = {'0', '1'};
preprocessing.smoothing                       = {'no', 'yes'};
preprocessing.digitization                    = {'subject-specific', 'template'};
preprocessing.highpass                        = {'0.5', '0.1'};

% Set the selected preprocessing strategy
preprocessing.selectedStrategy.valueArray = preprocStrategyValueArray;
preprocessing.selectedStrategy.prefix     = ['preproc_strategy' ...
    sprintf('_%d',preprocessing.selectedStrategy.valueArray)];

% Set the root directory for saving preprocessing results
preprocessing.root                         = fullfile(resultroot);

end