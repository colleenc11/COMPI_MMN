function D = compi_preprocessing(id, options)
% -------------------------------------------------------------------------
% Performs all analysis steps for one subject of the COMPI study (up until 
% first level modelbased statistics)
%
%   IN:     id          subject identifier string, e.g. '0001'
%           options     as set by compi_set_analysis_options();
%
%   OUT:    D           Data structure of SPM EEG Analysis
% ------------------------------------------------------------------------- 

%% Set paths and files
details = compi_get_subject_details(id, options); % subject-specific information

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('preprocessing_ssp', 'compi', id, options.eeg.preproc);

% general analysis options
keep   = options.eeg.preproc.keep;

if ~exist(details.eeg.preproot, 'dir')
    mkdir(details.eeg.preproot);
end
cd(details.eeg.preproot);

%% Preprocessing
try
    % check for previous preprocessing
    D = spm_eeg_load(details.eeg.prepfile);
    disp(['Subject ' id ' has been preprocessed before.']);
    if options.eeg.preproc.overwrite
        clear D;
        disp('Overwriting...');
        error('Continue to preprocessing script');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Preprocessing subject ' id ' ...']);

    %-- preparation --------------------------------------------------%
    spm('defaults', 'eeg');
    spm_jobman('initcfg');
    
    % Convert BDF files
    D = compi_eeg_convert(details.files.eeg);
    fprintf('\nConversion done.\n\n');

    % Start trigger and deviant represented by value 1. Changing start 
    % trigger value to 4 so this won't be used for epoching later.
    ev = D.events;
    for i = 1:6 % assume start trigger in first few events
        if ev(i).value == 1 & ev(i+1).value == 2
            ev(i).value = 4;
            disp('Changed event value of start trigger.');
            break
        end
    end
    D = events(D, 1, ev);

    % Project / interpolate channel TP7 for affected subjects
    if details.eeg.preproc.swap
        montage = compi_montage_swap_channels(id);
        D = tnueeg_do_montage(D, montage, options);
        fprintf('\nChannel swapping done.\n\n');
    end


    %-- set channel types (EEG, EOG) -------------------------------------%
    if ~exist(details.eeg.channeldef, 'file')
        chandef = compi_channel_definition(details);
    else
        load(details.eeg.channeldef);
    end
    D = tnueeg_set_channeltypes(D, chandef, options);
    fprintf('\nChanneltypes done.\n\n');


    %-- do montage (rereferencing, but keep EOG channel)------------------%
    if ~exist(options.eeg.montage, 'file')
        error('Please create a montage file first.');
    end
    D = tnueeg_do_montage(D, options.eeg.montage, options);
    fprintf('\nMontage done.\n\n');
    
    % diagnostics: save image of montage matrix
    compi_create_montage_matrix(id, details, options);


    %-- filtering --------------------------------------------------------%
    % filter & downsample
    D = tnueeg_filter(D, 'high', options);
    switch options.eeg.preproc.downsample
        case 'yes'
            D = tnueeg_downsample(D, options);
    end
    D = tnueeg_filter(D, 'low', options);
    fprintf('\nFilters & Downsampling done.\n\n');
    

    %-- eye blink detection ----------------------------------------------%
    % detect eye blinks based on standard deviation
    Dm = compi_eyeblink_detection_spm(D, id, details, options);

    ebstats.numEyeblinks = tnueeg_count_blink_artefacts(Dm);
    

    %-- trial definition -------------------------------------------------%
    % epoch according to trial definition
    if ~exist(details.eeg.trialdefinition, 'file')
        trialdef = compi_trial_definition(options, details);
    else
        load(details.eeg.trialdefinition);
    end
    

    %-- eyeblink rejection -----------------------------------------------%
    trialdefForReject.labels = {trialdef.conditionlabel};
    trialdefForReject.values = {trialdef.eventvalue};
    switch lower(options.eeg.preproc.eyeCorrMethod)
        case 'reject'
            [D, ~, ebstats.nExcluded, ebstats.idxExcluded, ebstats.nTrials, fh] = ...
                tnueeg_eyeblink_rejection_on_continuous_eeg(Dm, trialdefForReject, options);

            saveas(fh, details.eeg.eyeblinkoverlapfigure{f}, 'fig');
            close(fh);
            
    end

    save(details.eeg.eyeblinkrejectstats, 'ebstats');
    
    
    %-- experimental epoching --------------------------------------------%
    De = tnueeg_epoch_experimental(D, trialdef, options);
    fprintf('\nExperimental epoching done.\n\n');
    
    % Remove redundant events in preprocessed data
    % toneevents = compi_remove_redundant_events(De, trialdef, options);
    toneevents = cellfun(@(x) x(1), De.events, 'UniformOutput', false);
    toneevents{1,1} = De.events{1,1}(2); % fix first event extracted

    De = events(De, 1:numel(toneevents), toneevents);
    save(De);
    
    % diagnostics: save information about total events found
    nEvents = size(De,3);
    fprintf('\n\n----- Found a total of %s stimulus events from D.-----\n\n', ...
        num2str(nEvents));
    save(details.eeg.totalevents, 'nEvents');


    %-- eye blink detection based on eye channels ------------------------%
    switch lower(options.eeg.preproc.eyeCorrMethod)
        case {'berg', 'ssp','pssp'}
            S = [];
            S.D = Dm;
            S.timewin = options.eeg.preproc.eyeblinkwin;
            S.trialdef(1).conditionlabel = 'eyeblink';
            S.trialdef(1).eventtype = 'artefact_eyeblink';
            S.trialdef(1).eventvalue = 'VEOG';
            S.trialdef(1).trlshift = 0;
            S.bc = 0;
            S.prefix = 'e';
            S.eventpadding = 0;
            
            Da = spm_eeg_epochs(S);
            
            if ~keep, delete(S.D); end          
    end
    fprintf('\nRun-specific preprocessing done.\n\n');


    %-- eye blink correction & headmodel ---------------------------------%
    fid = details.eeg.fid;

    switch lower(options.eeg.preproc.eyeCorrMethod)
        case 'reject'
            %-- headmodel ------------------------------------------------%
            hmJob = dmpad_headmodel_job(De, fid, details, options);
            spm_jobman('run', hmJob);
            D = reload(De);
            
        case {'berg', 'ssp','pssp'}
            %-- headmodel ------------------------------------------------%
            hmJob = dmpad_headmodel_job(De, fid, details, options);
            spm_jobman('run', hmJob);            
            D = reload(De);
            
            % Get spatial confounds from EB epochs
            switch lower(options.eeg.preproc.eyeCorrMethod)
                case 'pssp'
                    % Remove wrong eyeblink trials before computing confound
                    % components
                    if isfield(options.eeg.preproc.artifact, 'lowPassFilter')
                        filterOptions.eeg.preproc.lowpassfreq = options.eeg.preproc.artifact.lowPassFilter;
                        filterOptions.eeg.preproc.keep = 1;
                        DaF = tnueeg_filter(Da, 'low', filterOptions);
                        DaNew = dmpad_reject_eyeblink_artefacts_for_eyeblink_correction(...
                            DaF, options);
                    else
                        DaNew = dmpad_reject_eyeblink_artefacts_for_eyeblink_correction(...
                            Da, options);
                    end
                    if isfield(details.eeg.preproc.artifact, 'channelLabelforRejection')
                        DaNew = badchannels(DaNew,details.eeg.preproc.artifact.channelLabelforRejection,1);
                    end

                    % Compute spatial confounds based on artefacts
                    Da1 = dmpad_get_spatial_confounds(DaNew, details, options);
                
                case {'berg', 'ssp'}
                    % Compute spatial confounds based on artefacts
                    S = [];
                    S.D = Da;
                    S.method = 'SVD';
                    S.timewin = options.eeg.preproc.eyeblinkwin;
                    S.ncomp = details.eeg.preproc.nComponentsforRejection;
                    S.conditions = 'eyeblink';
                    Da1 = spm_eeg_spatial_confounds(S);
            end
            
            % diagnostics: save EB components (confounds) figure
            if ~exist(fullfile(options.roots.diag_eeg, 'EB_confounds'), 'dir')
                mkdir(fullfile(options.roots.diag_eeg, 'EB_confounds'));
            end
    
            saveas(gcf,details.eeg.eyeblinkconfoundsfigure,'fig');
            saveas(gcf, fullfile(options.roots.diag_eeg, 'EB_confounds', [id '_EB_confounds']),'png');
            
            
            % add spatial confounds to condition epochs
            badChan = badchannels(Da1);
            if ~isempty(badChan)
                D = badchannels(D, badChan, ones(1, numel(badChan)));
            end

            S = [];
            S.D = D;
            S.method = 'SPMEEG';
            S.conffile = fullfile(Da1);
            D = spm_eeg_spatial_confounds(S);
            
            
            if ~keep, delete(Da1); end
            
            D = units(D, D.indchantype('EEG'), 'uV');
            save(D);
            
            % correct eyeblinks
            S = [];
            S.D = D;
            S.correction = options.eeg.preproc.eyeCorrMethod;
            D = spm_eeg_correct_sensor_data(S);
            save(D);
            
            if ~keep
                S.D = reload(S.D);
                delete(fullfile(S.D.path, S.D.inv{1}.gainmat));
                delete(S.D);
            end
            
    end

    D = copy(reload(D), details.eeg.prepfilename);

end

end
