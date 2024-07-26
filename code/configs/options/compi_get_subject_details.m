function details = compi_get_subject_details(id, options)
% ------------------------------------------------------------------------- 
% COMPI_GET_SUBJECT_DETAILS constructs directory and file paths for a given
% subject ID and options.
% IN:   id:      Subject ID
%       options: Struct containing experiment details, paths, and other parameters.
% OUT:  details: Struct with paths and filenames for the specific subject.
% ------------------------------------------------------------------------- 

% Check if subject ID belongs to any group
if ~ismember(id, options.subjects.all)
    error('Subject %s does not belong to any group %s. Please choose right options-struct.', ...
        id, options.eeg.part);
end

% Paths and directories
details.id = sprintf('COMPI_%s', id);

%------------------------
% Data directories
%------------------------
details.dirs.raw_eeg        = fullfile(options.roots.data, 'mmn', details.id, 'raw_EEG');
details.dirs.raw_behav      = fullfile(options.roots.data, 'mmn', details.id, 'behav');

%------------------------
% Result directories
%------------------------
details.dirs.results_eeg    = fullfile(options.roots.subjects, details.id);
details.dirs.results_hgf    = fullfile(options.roots.subjects, details.id, 'hgf');
details.dirs.preproc        = fullfile(options.roots.subjects, details.id, 'spm_preproc');

%------------------------
% Files
%------------------------
% Behavioral data files
details.files.behav_eeg     = fullfile(details.dirs.raw_behav, [details.id '_MMN_EEG_task.mat']);

% EEG data files
details.files.eeg           = fullfile(details.dirs.raw_eeg, [details.id '.bdf']);


%% EEG specific details

details.eeg.montage     = options.eeg.montage;
details.eeg.channels    = fullfile(options.roots.config, 'compi_eeg_channels.mat');
details.eeg.channeldef  = fullfile(details.dirs.raw_eeg, 'compi_chandef.mat');

% Fiducials
details.eeg.fid.labels  = {'NAS'; 'LPA'; 'RPA'};
details.eeg.fid.data    = [1, 85, -41; -83, -20, -65; 83, -20, -65];
        
        
%% Common details for subjects

details.eeg.sfxFilter           = 'outcomes'; % labeling the certain kind of analysis
details.eeg.raw                 = fullfile(details.dirs.raw_eeg);
details.eeg.subproname          = sprintf('COMPI_%04d', str2num(id));
details.eeg.subjectroot.results = fullfile(options.roots.subjects, details.eeg.subproname);

%% Swap channels TP7 and FT9 for the affected subjects
switch id
    case {'0118'}
       details.eeg.preproc.swap = 1;
    otherwise
       details.eeg.preproc.swap = 0;
end

%% Subject Specific Eye Blink Detection Metrics

% Eye-blink detection threshold
switch options.eeg.preproc.eyeDetectionThreshold
    case 'subject-specific'
        switch id
            case {'0106'}
                details.eeg.preproc.eyeBlinkThreshold = 2.5;
            case {'0122'}
                details.eeg.preproc.eyeBlinkThreshold = 2;
            otherwise
                details.eeg.preproc.eyeBlinkThreshold = options.eeg.preproc.eyeDetectionThresholdDefault;
        end
end

% Eye-blink correction type
switch options.eeg.preproc.eyeCorrType
    case 'subject-specific'
        switch id 
            case {'0117', '0123', '0124', '0129', '0102', '0136'}
                details.eeg.preproc.eyeCorrMethod = 'pssp';
            otherwise
                details.eeg.preproc.eyeCorrMethod = options.eeg.preproc.eyeCorrMethod;
        end
end

% Eye-blink number of components
switch options.eeg.preproc.eyeComponentThreshold
    case 'subject-specific'
        switch id
            case {'0102', '0119', '0125', '0134', '0136'}
                details.eeg.preproc.nComponentsforRejection = 2;
            otherwise
                details.eeg.preproc.nComponentsforRejection = options.eeg.preproc.nComponentsforRejection;
        end
end

% Artefact bad trial threshold
details.eeg.preproc.artifact.badtrialthresh = options.eeg.preproc.badtrialthresh;

%% Additional EEG file and directory paths

details.eeg.prepfilename    = [id '_' details.eeg.sfxFilter];
details.eeg.preproot        = fullfile(details.eeg.subjectroot.results, 'spm_preproc');

details.eeg.logfile         = fullfile(details.eeg.preproot, [details.eeg.subproname '.log']);
details.eeg.trialStats      = fullfile(details.eeg.preproot, 'trial_stats');


% Create subjects results directory for current preprocessing strategy
[~,~] = mkdir(details.eeg.preproot);

%% Preprocessed data common to all subjects

% Preprocessed File
details.eeg.prepfile        = fullfile(details.eeg.preproot, [details.eeg.prepfilename '.mat']);

details.eeg.totalevents   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_total_event_IDs.mat']);
details.eeg.montagefigure   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_montage.fig']);
details.eeg.trialdefinition = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_trialdef.mat']);

% Eye blink correction figures
details.eeg.eyeblinkdetectionfigure   = fullfile(details.eeg.preproot, [details.eeg.subproname '_EB_detection.fig']);
details.eeg.eyeblinkconfoundsfigure   = fullfile(details.eeg.preproot, [details.eeg.subproname '_EB_confounds.fig']);
details.eeg.componentconfoundsfigure  = fullfile(details.eeg.preproot, [details.eeg.subproname '_EB_componentconfounds.fig']);
details.eeg.eyeblinkoverlapfigure     = fullfile(details.eeg.preproot, [details.eeg.subproname 'EB_trial_overlap.fig']);

% Preprocessing stats
details.eeg.goodtrials                = fullfile(details.eeg.preproot, [details.eeg.subproname '_goodtrials.mat']);
details.eeg.eyeblinkrejectstats       = fullfile(details.eeg.preproot, [details.eeg.subproname '_EB_rejection_stats.mat']);


% Model design files
details.eeg.firstLevelDesignFileInit     = fullfile(options.roots.behav, [options.eeg.stats.design '.mat']);
details.eeg.firstLevelDesignFileEBPruned = fullfile(options.roots.behav, [options.eeg.stats.design '_EBpruned.mat']);
details.eeg.firstLevelDesignFilePruned   = fullfile(options.roots.behav, [options.eeg.stats.design '_Pruned.mat']);

if options.eeg.stats.designPruned
    details.eeg.firstLevelDesignFile = details.eeg.firstLevelDesignFilePruned;
else
    details.eeg.firstLevelDesignFile = details.eeg.firstLevelDesignFileInit;
end

% Regressor trajectory figure
details.eeg.regressorfigure           = fullfile(details.eeg.preproot, [details.eeg.subproname '_regressor_traj.fig']);
        
%% Single-trial analysis file names
% Image Conversion
details.eeg.conversion.sensor.convRoot  = fullfile(details.eeg.preproot, ['sensor_', details.eeg.prepfilename , '/']);
details.eeg.conversion.sensor.convFile  = fullfile(details.eeg.conversion.sensor.convRoot, 'condition_tone.nii');
details.eeg.conversion.sensor.smoofile  = fullfile(details.eeg.conversion.sensor.convRoot, 'smoothed_condition_tone.nii');

details.eeg.conversion.source.convRoot  = fullfile(details.eeg.preproot, ['source_',id,'_', details.eeg.sfxFilter, '/']);
details.eeg.conversion.source.convFile  = fullfile(details.eeg.conversion.source.convRoot, 'condition_Outcome.nii');
details.eeg.conversion.source.smoofile  = fullfile(details.eeg.conversion.source.convRoot, 'smoothed_condition_Outcome.nii');

% First Level Analysis Names
details.eeg.firstLevel.sensor.prefixBetaWave = ['w_' options.eeg.stats.design];
details.eeg.firstLevel.sensor.prefixPreproc  = '';
details.eeg.firstLevel.sensor.prefixImages   = ['sensor_' details.eeg.firstLevel.sensor.prefixPreproc];
details.eeg.firstLevel.sensor.pathImages     = details.eeg.conversion.sensor.convRoot;
details.eeg.firstLevel.sensor.fileBetaWave   = fullfile(details.eeg.preproot, [details.eeg.firstLevel.sensor.prefixBetaWave, details.eeg.prepfilename  '.mat']);
details.eeg.firstLevel.sensor.pathStats      = fullfile(details.eeg.subjectroot.results, 'stats', [details.eeg.firstLevel.sensor.prefixImages, options.eeg.stats.design]);

details.eeg.firstLevel.source.pathImages     = details.eeg.conversion.source.convRoot;
details.eeg.firstLevel.source.pathStats      = fullfile(details.eeg.subjectroot.results, 'stats', 'source');
details.eeg.firstLevel.source.prefixImages   = 'source_';

details.eeg.source.savefilename              = fullfile(details.eeg.preproot, ['B' id '_' details.eeg.sfxFilter '.mat']);
details.eeg.source.iidsavefilename           = fullfile(details.eeg.preproot, ['IID_B' id '_' details.eeg.sfxFilter '.mat']);


% take smoothed or unsmoothed images
switch options.eeg.preproc.smoothing
    case 'yes'
        details.eeg.firstLevel.sensor.fileImage  = details.eeg.conversion.sensor.smoofile;
        details.eeg.firstLevel.source.fileImage  = details.eeg.conversion.source.smoofile;
    case 'no'
        details.eeg.firstLevel.sensor.fileImage  = details.eeg.conversion.sensor.convFile;
        details.eeg.firstLevel.source.fileImage  = details.eeg.conversion.source.convFile;
end

%% ERP analysis file names

details.eeg.erp.root                = fullfile(details.eeg.subjectroot.results, 'erp');
details.eeg.erp.contrastWeighting   = 1;
details.eeg.erp.contrastPrefix      = 'diff_';
details.eeg.erp.contrastName        = 'mmn';
details.eeg.erp.difffile            = fullfile(details.eeg.erp.root, 'oddball', ['diff_oddball.mat']);
details.eeg.erp.sourcefile          = fullfile(details.eeg.erp.root, 'oddball', ['B' id '_binned_outcomes.mat']);
details.eeg.erp.erpfigs             = fullfile(details.eeg.erp.root, 'Figures');

details.eeg.erp.source.pathStats    = fullfile(details.eeg.erp.root, 'source');

%% EEG QC Figure Paths 
details.eeg.quality.root                    = fullfile(details.eeg.subjectroot.results, 'quality');
details.eeg.quality.initialtrials           = fullfile(details.eeg.quality.root, [details.eeg.subproname '_numTrialsInitial.mat']);
details.eeg.quality.eyeblinks               = fullfile(details.eeg.quality.root, [details.eeg.subproname '_numEyeblinks.mat']);
details.eeg.quality.eyeblinkdetectionfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_eyeblinkdetection.fig']);
details.eeg.quality.eyeblinkconfoundsfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_eyeblinkconfounds.fig']);

details.eeg.quality.epoched_EB_uncorrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_uncorrected.mat']);
details.eeg.quality.average_EB_uncorrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_uncorrected_averaged.mat']);
details.eeg.quality.epoched_EB_corrected   = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_corrected.mat']);
details.eeg.quality.average_EB_corrected   = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_corrected_averaged.mat']);

details.eeg.quality.averageeyeblinkcorrectionfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_averageeyeblinkcorrection_channels.fig']);

%% logging, e.g. single subject batches
details.eeg.log.batches.root = fullfile(details.eeg.subjectroot.results, 'batches');
details.eeg.log.sfxTimeStamp = sprintf('_%s', datestr(now, 'yymmdd_HHMMSS'));
details.eeg.log.batches.statsfile = fullfile(details.eeg.log.batches.root, ...
    sprintf('%s%s.m', 'batch_COMPI_stats_adaptable', details.eeg.log.sfxTimeStamp));

end

