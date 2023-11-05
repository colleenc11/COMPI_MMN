function compi_calculate_difference_wave(D, id, label, options, doPlot)
% -------------------------------------------------------------------------
% COMPI_CALCULATE_DIFFERENCE_WAVE Calculate difference waveform.
%   IN:     D               (averaged) M/EEG data set
%           id              subject identifier, e.g '0101'
%           label           condition name
%           options         structure of options
%           doPlot (optional)   1 for plotting subject's ERP and saving a
%                               figure, 0 otherwise
%   OUT:    -
% -------------------------------------------------------------------------

%% paths and files
details = compi_get_subject_details(id, options);

%% Calculate difference waveform
switch label
    case 'oddball'
        Ddiff = process_data(D, indtrial(D, 'standard'), indtrial(D, 'deviant'), label, details, options);
        
    case 'oddball_stable'
        Ddiff = process_data(D, indtrial(D, 'standStab'), indtrial(D, 'devStab'), label, details, options);
        
    case 'oddball_volatile'
        Ddiff = process_data(D, indtrial(D, 'standVol'), indtrial(D, 'devVol'), label, details, options);
        
    otherwise
        Ddiff = process_data(D, indtrial(D, 'low'), indtrial(D, 'high'), label, details, options);
end
disp(['Computed the difference wave and smoothed images for subject ' id ' for ' label]);

% Plot subejcts ERP
if doPlot
    save_plot(Ddiff, label, id, options);
end

end

%% helper functions
function Dfinal = process_data(D, idxLow, idxHigh, label, details, options)
    
    % Set weights and compute the actual contrast
    weights = zeros(1, ntrials(D));
    weights(idxHigh) = 1;
    weights(idxLow) = -1;
    condlabel = {'diff'};
    
    % Sanity check for logfile
    disp('Difference wave will be computed using:');
    disp(weights);
    disp('as weights on these conditions:');
    disp(conditions(D));
    
    Ddiff = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
    copy(Ddiff, fullfile(details.eeg.erp.root, label, ['diff_' label '.mat']));
    
    % Conversion and smoothing
    prepfile = fullfile(details.eeg.erp.root, label, ['diff_' label '.mat']);
    Dfinal = spm_eeg_load(prepfile);
    [images, ~] = tnueeg_convert2images(Dfinal, options);
    tnueeg_smooth_images(images, options);
end


function save_plot(D, label, id, options)

    details = compi_get_subject_details(id, options);

    triallist = {'diff', 'diff waveform', [0 1 0]};
    h = tnueeg_plot_subject_ERPs(D, options.eeg.erp.electrode, triallist);
    h.Children(2).Title.String = ['Subject ' id ': ' label ' MMN'];
    
    switch label
        case 'oddball_stable'
            savefig(h, fullfile(details.eeg.erp.erpfigs, [label '_stable_MMN.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_stable_MMN']), 'png');
            fprintf('\nSaved a stable phase MMN ERP plot for subject %s\n\n', id);
            
        case 'oddball_volatile'
            savefig(h, fullfile(details.eeg.erp.erpfigs, [label '_volatile_MMN.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_volatile_MMN']), 'png');
            fprintf('\nSaved a volatile phase MMN ERP plot for subject %s\n\n', id);
            
        otherwise
            savefig(h, fullfile(details.eeg.erp.erpfigs, [label '_diff_ERP.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_' label '_diff']), 'png');
            fprintf('\nSaved an MMN ERP plot for subject %s\n\n', id);
    end
    
    close all;
end
