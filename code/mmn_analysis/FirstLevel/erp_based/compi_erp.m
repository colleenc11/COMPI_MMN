function D = compi_erp(id, options, doPlot)
% -------------------------------------------------------------------------
% COMPI_ERP Computes ERPs for one subject from the COMPI study.
%   IN:     id                  subject identifier, e.g '0101'
%           options             as set by compi_mmn_options();
%           doPlot (optional)   1 for plotting subject's ERP and saving a
%                               figure, 0 otherwise
%   OUT:    D                   preprocessed data set
% -------------------------------------------------------------------------

% plotting yes or no
if nargin < 3
    doPlot = 1;
end

%% Get subject details
details = compi_get_subject_details(id, options); % subject-specific information

fileDesignMatrix = fullfile(details.dirs.preproc, 'design.mat');

% prepare spm
spm('defaults', 'EEG');

% record what we're doing
diary(details.eeg.logfile);

try
    % check for previous ERP analyses
    D = spm_eeg_load(details.eeg.erp.difffile);
    disp(['Subject ' id ' has been averaged before.']);
    if options.eeg.preproc.overwrite
        clear D;
        disp('Overwriting...');
        error('Continue to ERP script');
    else
        disp('Nothing is being done.');
    end
catch
    fprintf('\nAveraging subject %s ...\n\n', id);
    
    %-- preparation -------------------------------------------------------------------------------%
    % check destination folder
    if ~exist(details.eeg.erp.root, 'dir')
        mkdir(details.eeg.erp.root);
    end
    if ~exist(details.eeg.erp.erpfigs, 'dir')
        mkdir(details.eeg.erp.erpfigs);
    end
    cd(details.eeg.erp.root);
    
    % work on final preprocessed file
    Dprep = spm_eeg_load(details.eeg.prepfile);
    
    %-- redefinition ------------------------------------------------------------------------------%
    % get new condition names
    factorNames = options.eeg.stats.regressors;

    for i = 1:numel(factorNames)

        % reload D for each factor
        D = Dprep;

        % get conditions
        switch options.eeg.stats.design
            
            case {'oddball', 'oddball_stable', 'oddball_volatile'}
                condlist = compi_oddball_conditions(options.eeg.stats.design, options);
            
            otherwise
                design      = getfield(load(fileDesignMatrix), 'design');
                condlist    = erp_lowhighPE_conditions(design.(factorNames{i}), ...
                    factorNames{i}, options);
                savefig(fullfile(details.eeg.erp.erpfigs, [factorNames{i} '_values.fig']));
                close all;
        end
                
        % correct for eyeblinks if rejection method used
        switch lower(options.eeg.preproc.eyeCorrMethod)
           case 'reject'    
               condlist      = mmn_correct_conditions_for_eyeblinktrials(condlist, details.eeg.goodtrials);
        end                
 
        % redefine trials for averaging
        Drefined = tnueeg_redefine_conditions(D, condlist);
        Dsaved = copy(Drefined, fullfile(details.eeg.erp.root, factorNames{i}, ['redef_' factorNames{i} '.mat']));
        disp(['Redefined conditions for subject ' id]);
        
        %-- averaging ---------------------------------------------------------------------------------%
        Daveraged = tnueeg_average(Dsaved, options);
        disp(['Averaged over trials for subject ' id]);
        
        % in case of robust filtering: re-apply the low-pass filter
        switch options.eeg.erp.averaging
            case {'r', 'robust'}
                % make sure we don't delete ERP files during filtering
                options.eeg.preproc.keep = 1;
                Dfiltered = tnueeg_filter(Daveraged, 'low', options);
                disp(['Re-applied the low-pass filter for subject ' id]);

                Dfinal = copy(Dfiltered, fullfile(details.eeg.erp.root, factorNames{i}, [factorNames{i} '.mat']));
            case {'s', 'simple'}
                % do nothing
                Dfinal = copy(Daveraged, fullfile(details.eeg.erp.root, factorNames{i}, [factorNames{i} '.mat']));
        end

        %-- ERP plot ----------------------------------------------------------------------------------%
        
        % channel to plot
        chanlabel = options.eeg.erp.electrode;

        switch factorNames{i}
            case {'oddball'}
                triallist = {'standard', 'Standard Tones', [0 0 1]; ...
                    'deviant', 'Deviant Tones', [1 0 0]}; 

            case {'oddball_stable', 'oddball_volatile'}
                triallist = {'standStab', 'Stable Standard', [0.2 0.2 0]; ...
                    'standVol', 'Volatile Standard', [0.2 0.4 0];...
                    'devStab', 'Stable Deviant', [0.2 0.6 1]; ...
                    'devVol', 'Volatile Deviant', [0.2 0.8 1]}; 

            otherwise
                triallist = {'low', ['Lowest ' num2str(options.eeg.erp.percentPe) ' %'], [0 0 1]; ...
                    'high', ['Highest ' num2str(options.eeg.erp.percentPe) ' %'], [1 0 0]};
        end

        if doPlot
            h = tnueeg_plot_subject_ERPs(Dfinal, chanlabel, triallist);
            h.Children(2).Title.String = ['Subject ' id ': ' options.eeg.stats.design ' of ' factorNames{i} ' ERPs'];
            savefig(h, fullfile(details.eeg.erp.erpfigs, [factorNames{i} '_ERP.fig']));

            if ~exist(fullfile(options.roots.diag_eeg, 'ERPs'), 'dir')
                mkdir(fullfile(options.roots.diag_eeg, 'ERPs'));
            end
            saveas(h, fullfile(options.roots.diag_eeg, 'ERPs', [id '_' factorNames{i}]), 'png');
            fprintf('\nSaved an ERP plot for subject %s\n\n', id);
            close all
        end

        %-- image conversion ----------------------------------------------------------------------------%
        
        disp(['Converting subject ' id ' ...']);
        % reload EEG data
        prepfile = fullfile(details.eeg.erp.root, factorNames{i}, [factorNames{i} '.mat']);
        D = spm_eeg_load(prepfile);

        % convert EEG data
        [images, ~] = tnueeg_convert2images(D, options);
        disp(['Converted EEG data for subject ' id]);
    
        % and smooth the resulting images
        tnueeg_smooth_images(images, options);
        disp(['Smoothed images for subject ' id]);


        %-- difference waves --------------------------------------------------------------------------%
        compi_calculate_difference_wave(Dfinal, id, factorNames{i}, options, doPlot);

    end
end

close all

diary OFF
end
