function [D] = compi_eyeblink_detection_spm(D, id, details, options)
% ------------------------------------------------------------------------- 
% COMPI_EYEBLINK_DETECTION_SPM: Detect and mark eye blink artifacts in EEG 
% data using SPM.
%   IN:     D           EEG data structure
%           id          subject identifier string, e.g. '0001'
%           details     subject-specific options
%           options     as set by compi_set_analysis_options();
% ------------------------------------------------------------------------- 

% Initialize SPM parameters
S = [];
S.D = D;
S.mode = 'mark';
S.badchanthresh = 1;
S.methods(1).channels = {'VEOG'};
S.methods(1).fun = 'eyeblink';

% Set eye blink detection threshold based on options
switch options.eeg.preproc.eyeDetectionThreshold
    case 'subject-specific'
        S.methods(1).settings.threshold = details.eeg.preproc.eyeBlinkThreshold;
    case 'default'
        S.methods(1).settings.threshold = options.eeg.preproc.eyeDetectionThresholdDefault;
end

S.methods(1).settings.excwin = 0;
S.append = true;
S.prefix = 'a';

% Perform eye blink artifact detection using SPM
D = compi_spm_eeg_artefact(S);

%% diagnostics: save EB detection plot
if ~exist(fullfile(options.roots.diag_eeg, 'EB_detection'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'EB_detection'));
end

title(['Eye Blink Detection SD ' num2str(details.eeg.preproc.eyeBlinkThreshold)])

% Save the detection plot as a figure and PNG file
saveas(gcf, details.eeg.eyeblinkdetectionfigure, 'fig');
saveas(gcf, fullfile(options.roots.diag_eeg, 'EB_detection', ...
    [id '_EB_detection']),'png');

fprintf('\nEye blink detection done.\n\n');

% Optionally delete the intermediate data if specified in options
if ~options.eeg.preproc.keep, delete(S.D); end

end