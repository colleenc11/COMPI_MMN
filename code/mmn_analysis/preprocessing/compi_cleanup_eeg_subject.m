function compi_cleanup_eeg_subject(id, options)
% Deletes previous preproc/stats files of analysis specified in options, if
% the same analysis step should be done again
% e.g. deletes preproc files, if preproc is a pipeline option
%
% IN
%   doDeleteAllAnalyses  (Default: false) delete all preprocessed data and analyses for a
%                       subject

details = compi_get_subject_details(id, options);

%% now choose what to delete
doCreateRegressors      = ismember('create_behav_regressors', options.eeg.pipe.executeStepsPerSubject);
doCorrectEyeBlinks      = ismember('correct_eyeblinks', options.eeg.pipe.executeStepsPerSubject);
doIgnoreRejectTrials    = ismember('ignore_reject_trials', options.eeg.pipe.executeStepsPerSubject);
doPhaseERP              = ismember('run_phase_erp', options.eeg.pipe.executeStepsPerSubject);
doRegressorERP          = ismember('run_regressor_erp', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSensor        = ismember('run_stats_sensor', options.eeg.pipe.executeStepsPerSubject);
doRunSources            = ismember('extract_sources', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSource        = ismember('run_stats_source', options.eeg.pipe.executeStepsPerSubject);
doComputeBetaWave       = ismember('compute_beta_wave', options.eeg.pipe.executeStepsPerSubject);

filesToDelete = {}; % could also be folders


if doCreateRegressors
    filesToDelete{end+1} = details.eeg.firstLevelDesignFileInit;
end

if doCorrectEyeBlinks
    filesToDelete{end+1} = details.eeg.preproot; % since this is the first preproc step, delete the folder
end

if doIgnoreRejectTrials
    filesToDelete{end+1} = details.eeg.firstLevelDesignFilePruned;
end

%%% TO DO: seperate options %%%
if doPhaseERP || doRegressorERP
    filesToDelete{end+1} = details.eeg.erp.root;
end

if doRunStatsSensor
    filesToDelete{end+1} = details.eeg.firstLevel.sensor.fileImage;
    filesToDelete{end+1} = details.eeg.firstLevel.sensor.pathStats;
end

if doRunSources
    filesToDelete{end+1} = details.eeg.source.savefilename;
end

if doRunStatsSource
    filesToDelete{end+1} = details.eeg.firstLevel.source.fileImage;
    filesToDelete{end+1} = details.eeg.firstLevel.source.pathStats;
end

if doComputeBetaWave
    filesToDelete{end+1} = details.eeg.firstLevel.sensor.fileBetaWave;
end


%% Now loop deletion, check if dirs (recursive delete!) or files

nFiles = numel(filesToDelete);

for f = 1:nFiles
    if exist(filesToDelete{f}, 'dir')
        % recursive delete
        rmdir(filesToDelete{f}, 's'); % s for recursive and nonempty folder delete!
    else
        if exist(filesToDelete{f}, 'file')
            delete(filesToDelete{f});
        end
    end
end