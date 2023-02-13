function compi_calculate_difference_wave(D, id, label, options, doPlot)
% COMPI_CALCULATE_DIFFERENCE_WAVE Calculate difference waveform.
%   IN:     D           - (averaged) M/EEG data set
%           options     - structure of options


% paths and files
details = compi_get_subject_details(id, options);

switch label

    case 'oddball'

        % determine condition order within the D object
        idxStand = indtrial(D, 'standard');
        idxDev = indtrial(D, 'deviant');
        
        % set weights such that we substract standard trials from deviant
        % trials, give the new condition a name
        weights = zeros(1, ntrials(D));
        weights(idxDev) = 1;
        weights(idxStand) = -1;
        condlabel = {'mmn'};
        
        % sanity check for logfile
        disp('Difference wave will be computed using:');
        disp(weights);
        disp('as weights on these conditions:');
        disp(conditions(D));
        
        % compute the actual contrast
        Ddiff = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
        copy(Ddiff, fullfile(details.eeg.erp.root, label, ['diff_' label '.mat']));
        % copy(Ddiff, fullfile(details.eeg.erp.difffile,[label '.mat']));
        disp(['Computed the difference wave for subject ' id]);

        %-- Conversion and smoothing of difference waveform --------------------------------------------------%

        disp(['Converting subject ' id ' ...']);
        % reload EEG data
        prepfile = fullfile(details.eeg.erp.root, label, ['diff_' label '.mat']);
        D = spm_eeg_load(prepfile);
        % convert EEG data
        [images, ~] = tnueeg_convert2images(D, options);
        disp(['Converted EEG data for subject ' id ' for ' label]);
        % and smooth the resulting images
        tnueeg_smooth_images(images, options);
        disp(['Smoothed images for subject ' id ' for ' label]);
    
    case 'oddball_phases'

        %-- stable MMN --------------------------------------------------------------------------%

        % determine condition order within the D object
        idxStand = indtrial(D, 'standStab');
        idxDev = indtrial(D, 'devStab');
        
        % set weights such that we substract standard trials from deviant
        % trials, give the new condition a name
        weights = zeros(1, ntrials(D));
        weights(idxDev) = 1;
        weights(idxStand) = -1;
        condlabel = {'mmn'};
        
        % sanity check for logfile
        disp('Difference wave will be computed using:');
        disp(weights);
        disp('as weights on these conditions:');
        disp(conditions(D));
        
        % compute the actual contrast
        D_stable = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
        copy(D_stable, fullfile(details.eeg.erp.root, label, ['diff_stable_' label '.mat']));
        % copy(D_stable, fullfile(details.eeg.erp.difffile,'stable.mat'));
        disp(['Computed the difference wave for subject ' id]);

        %-- Conversion and smoothing of stable phase difference waveform ----------------------------%

        disp(['Converting subject ' id ' ...']);
        % reload EEG data
        prepfile = fullfile(details.eeg.erp.root, label, ['diff_stable_' label '.mat']);
        D_stable = spm_eeg_load(prepfile);
        % convert EEG data
        [images, ~] = tnueeg_convert2images(D_stable, options);
        disp(['Converted EEG data for subject ' id ' for ' label]);
        % and smooth the resulting images
        tnueeg_smooth_images(images, options);
        disp(['Smoothed images for subject ' id ' for ' label]);


        %-- volatile MMN --------------------------------------------------------------------------%

        % determine condition order within the D object
        idxStand = indtrial(D, 'standVol');
        idxDev = indtrial(D, 'devVol');
        
        % set weights such that we substract standard trials from deviant
        % trials, give the new condition a name
        weights = zeros(1, ntrials(D));
        weights(idxDev) = 1;
        weights(idxStand) = -1;
        condlabel = {'mmn'};
        
        % sanity check for logfile
        disp('Difference wave will be computed using:');
        disp(weights);
        disp('as weights on these conditions:');
        disp(conditions(D));
        
        % compute the actual contrast
        D_volatile = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
        copy(D_volatile, fullfile(details.eeg.erp.root, label, ['diff_volatile_' label '.mat']));
        %copy(D_volatile, fullfile(details.eeg.erp.difffile,'volatile.mat'));
        disp(['Computed the difference wave for subject ' id]);

        %-- Conversion and smoothing of volatile phase difference waveform ----------------------------%

        disp(['Converting subject ' id ' ...']);
        % reload EEG data
        prepfile = fullfile(details.eeg.erp.root, label, ['diff_volatile_' label '.mat']);
        D_volatile = spm_eeg_load(prepfile);
        % convert EEG data
        [images, ~] = tnueeg_convert2images(D_volatile, options);
        disp(['Converted EEG data for subject ' id ' for ' label]);
        % and smooth the resulting images
        tnueeg_smooth_images(images, options);
        disp(['Smoothed images for subject ' id ' for ' label]);

    otherwise
        
         % determine condition order within the D object
        idxLow = indtrial(D, 'low');
        idxHigh = indtrial(D, 'high');
        
        % set weights such that we substract standard trials from deviant
        % trials, give the new condition a name
        weights = zeros(1, ntrials(D));
        weights(idxHigh) = 1;
        weights(idxLow) = -1;
        condlabel = {'mmn'};
        
        % compute the actual contrast
        Ddiff = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
        copy(Ddiff, fullfile(details.eeg.erp.root, label, ['diff_' label '.mat']));
        disp(['Computed the difference wave for subject ' id]);

        % convert EEG data
        [images, ~] = tnueeg_convert2images(Ddiff, options);
        disp(['Converted EEG data for subject ' id]);
    
        % and smooth the resulting images
        tnueeg_smooth_images(images, options);
        disp(['Smoothed images for subject ' id]);

end


% plot MMN
triallist = {'mmn', 'MMN', [0 1 0]};
switch label
    
    case {'oddball_phases'}
        if doPlot
            h_stab = tnueeg_plot_subject_ERPs(D_stable, options.eeg.erp.electrode, triallist);
            h_stab.Children(2).Title.String = ['Subject ' id ': ' label ' MMN'];
            savefig(h_stab, fullfile(details.eeg.erp.erpfigs, [label '_stable_MMN.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_stable_MMN']), 'png');
            fprintf('\nSaved a stable phase MMN ERP plot for subject %s\n\n', id);
            close all;

            h_vol = tnueeg_plot_subject_ERPs(D_volatile, options.eeg.erp.electrode, triallist);
            h_vol.Children(2).Title.String = ['Subject ' id ': ' label ' MMN'];
            savefig(h_vol, fullfile(details.eeg.erp.erpfigs, [label '_volatile_MMN.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_volatile_MMN']), 'png');
            fprintf('\nSaved a volatile phase MMN ERP plot for subject %s\n\n', id);
            close all;
        end
    
    otherwise
        if doPlot
            h = tnueeg_plot_subject_ERPs(Ddiff, options.eeg.erp.electrode, triallist);
            h.Children(2).Title.String = ['Subject ' id ': ' label ' MMN'];
            savefig(h, fullfile(details.eeg.erp.erpfigs, [label '_diff_ERP.fig']));
            saveas(gcf, fullfile(options.roots.diag_eeg, 'ERPs', [id '_' label '_MMN']), 'png');
            fprintf('\nSaved an MMN ERP plot for subject %s\n\n', id);
            close all;
        end
end