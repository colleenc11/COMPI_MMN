function compi_ignore_reject_trials(id, options)
% -------------------------------------------------------------------------
% COMPI_IGNORE_REJECT_TRIALS Remove rejected trials due to eyeblinks and
% artefacts from design matrix.
%
% IN
%   id          subject id string, only number (e.g. '0101')
%   options     general analysis options as set in compi_mmn_options();
% ------------------------------------------------------------------------- 

%% paths and files
details = compi_get_subject_details(id, options);

%% remove rejected / bad trials
% Remove artefactual trials
badtrials = get_bad_trials(details);
design = remove_bad_trials(badtrials, options, details);

% save pruned design
save(fullfile(details.dirs.preproc, 'design_Pruned.mat'), 'design');

end

%% helper functions

function bt = get_bad_trials(details)
D = spm_eeg_load(details.eeg.prepfile);
bt = badtrials(D);
end

function design = remove_bad_trials(bt, options, details)

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

end