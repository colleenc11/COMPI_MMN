function options = compi_setup_roots(preprocStrategyValueArray, options)

% Main results folder
options.roots.results = fullfile(options.roots.project,'results',...
        sprintf('preproc_strategy_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d', preprocStrategyValueArray));

% Subject folder
options.roots.subjects = fullfile(options.roots.results,'subjects');

% Logfile folder roots
options.roots.log = fullfile(options.roots.results,'logfiles');

% Error folder roots
options.roots.err = fullfile(options.roots.results,'errors');

% EEG preprocessing diagnostics root
options.roots.diag_eeg = fullfile(options.roots.results,'diag_eeg');

% Behavior folder roots
options.roots.results_behav = fullfile(options.roots.results,'results_behav');

% Results sub-folder based on analysis type
options.roots.analysis = fullfile(options.roots.results, 'results', options.analysis.type);

% ERP sub-folder root
options.roots.erp = fullfile(options.roots.analysis,'results_erp');

% HGF sub-folder root
options.roots.results_hgf = fullfile(options.roots.analysis,'results_hgf');

%% Create folders
% Result folders
mkdir(options.roots.subjects);
mkdir(options.roots.results);
mkdir(options.roots.log);
mkdir(options.roots.err);
mkdir(options.roots.results_behav);
mkdir(options.roots.analysis);
mkdir(options.roots.erp);
mkdir(options.roots.results_hgf);


return