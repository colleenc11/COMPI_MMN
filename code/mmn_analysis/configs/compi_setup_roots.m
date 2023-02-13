function options = compi_setup_roots(task, modality, preprocStrategyValueArray, options)

switch modality
    case 'eeg'
    options.roots.results = fullfile(options.roots.project,'results', task, modality,...
        sprintf('preproc_strategy_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d', preprocStrategyValueArray));
    otherwise
        options.roots.results = fullfile(options.roots.project,'results', task, modality);
end

% Subject folder
options.roots.subjects = fullfile(options.roots.results,'subjects');

% Logfile folder roots
options.roots.log = fullfile(options.roots.results,'logfiles');

% Error folder roots
options.roots.err = fullfile(options.roots.results,'errors');

% EEG preprocessing diagnostics root
options.roots.diag_eeg = fullfile(options.roots.results,'diag_eeg');

% ERP folder roots
options.roots.erp = fullfile(options.roots.results,'results_erp');

% ERP folder roots
options.roots.results_hgf = fullfile(options.roots.results,'results_hgf');

%% Create folders
% Result folders
mkdir(options.roots.subjects);
mkdir(options.roots.results);
mkdir(options.roots.log);
mkdir(options.roots.err);
mkdir(options.roots.erp);
mkdir(options.roots.results_hgf);

return