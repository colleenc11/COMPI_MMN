function compi_ignore_reject_trials(id, options)
% -------------------------------------------------------------------------
% COMPI_IGNORE_REJECT_TRIALS Remove rejected trials due to eyeblinks and
% artefacts from design matrix.
%
% IN
%   id          subject id string, only number (e.g. '153')
%   options     general analysis options%
%               options = compi_set_analysis_options;
% ------------------------------------------------------------------------- 

% paths and files
details = compi_get_subject_details(id, options); % subject-specific information

switch lower(options.eeg.preproc.eyeCorrMethod)
    % first, remove rejected trials due to eyeblinks
    case 'reject'
        ebstats = getfield(load(details.eeg.eyeblinkrejectstats), 'ebstats');
        % we have to adjust the indices of excluded trials in run2 for the remaining number of
        % EB-free trials in run1 to make the indices fit to the merged file (after EB rejection,
        % before artefact rejection).
        nTrialsRemainingInFirstRun = ebstats(1).nTrials.Outcome;
        eyeblinks_run1 = ebstats(1).idxExcluded.Outcome;
        eyeblinks_run2 = ebstats(2).idxExcluded.Outcome + nTrialsRemainingInFirstRun;
        remove_eyeblink_trials(eyeblinks_run1, eyeblinks_run2, details);
end

% now, remove other artefactual trials
badtrials = get_bad_trials(details);
remove_bad_trials(badtrials, options, details);

end

function bt = get_bad_trials(details)
D = spm_eeg_load(details.eeg.prepfile);
bt = badtrials(D);
end

function remove_eyeblink_trials(eb1, eb2, details)

% get design matrix
design = getfield(load(details.eeg.firstLevelDesignFileInit), 'design');
fns = fieldnames(design);

% remove trials from run 1
for i = 1: numel(fns)
    fn = char(fns(i));
    design.(fn)(eb1) = [];
end

% remove trials from run 2
for i = 1: numel(fns)
    fn = char(fns(i));
    design.(fn)(eb2) = [];
end

% save pruned design
save(details.eeg.firstLevelDesignFileEBPruned, 'design');
end

function remove_bad_trials(bt, options, details)

% get design matrix
% if EB rejection, take the EBPruned, otherwise, the Init
if strcmpi(options.eeg.preproc.eyeCorrMethod, 'reject') && ...
        exist(details.firstLevelDesignFileEBPruned, 'file')
    design = getfield(load(fullfile(details.dirs.preproc, 'design.mat')), 'design');
else
    design = getfield(load(fullfile(details.dirs.preproc, 'design.mat')), 'design');
end
fns = fieldnames(design);

% remove trials
for i = 1: numel(fns)
    fn = char(fns(i));
    design.(fn)(bt) = [];
end

% save pruned design
save(fullfile(details.dirs.preproc, 'design_Pruned.mat'), 'design');
end