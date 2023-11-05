function options = compi_setup_roots(preprocStrategyValueArray, options)
%--------------------------------------------------------------------------
% COMPI_SETUP_ROOTS Create folder roots for analysis. 
% IN
%       preprocStrategyValueArray   preprocessing analysis options
%       options                     as set by compi_mmn_options();
% OUT   
%       options                     updated options structure with folder 
%                                   roots.
%--------------------------------------------------------------------------

% Main results folder
options.roots.results       = fullfile(options.roots.project,'results',...
                                sprintf('preproc_strategy_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d', ...
                                preprocStrategyValueArray));

% Subject folder
options.roots.subjects      = fullfile(options.roots.results,'subjects');

% Logfile folder roots
options.roots.log           = fullfile(options.roots.results,'logfiles');

% EEG preprocessing diagnostics root
options.roots.diag_eeg      = fullfile(options.roots.results,'diag_eeg');

% Results sub-folder based on analysis type
options.roots.analysis      = fullfile(options.roots.results, 'results', options.analysis.type);

% Behavior folder roots
options.roots.behav         = fullfile(options.roots.analysis,'results_behav');

% ERP sub-folder root
options.roots.erp           = fullfile(options.roots.analysis,'results_erp');

% HGF sub-folder root
options.roots.hgf           = fullfile(options.roots.analysis,'results_hgf');

% HGF sub-folder root
options.roots.source        = fullfile(options.roots.analysis,'results_source');

% Paper figures root
options.roots.paper_fig     = fullfile(options.roots.results,'paper_figs');

%% Create necessary folders

mkdir(options.roots.subjects);
mkdir(options.roots.results);
mkdir(options.roots.log);
mkdir(options.roots.analysis);
mkdir(options.roots.behav);
mkdir(options.roots.erp);
mkdir(options.roots.hgf);
mkdir(options.roots.source);
mkdir(options.roots.paper_fig);

return