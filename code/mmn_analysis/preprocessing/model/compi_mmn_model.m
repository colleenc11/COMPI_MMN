function compi_mmn_model(id, options)
% -------------------------------------------------------------------------
% COMPI_MMN_MODEL Simulates the beliefs of one subject from the COMPI 
% study and saves the trajectories for modelbased analysis of EEG data. All
% subjects receive same tone input in COMPI study.
% See mmn_binary_trialDef for calculation of tones.
%   IN:     id          - subject identifier, e.g '0101'
%           options     - the struct that holds all analysis options
%   OUT:    design      - the design file which holds the modelbased 
%                         regressors for this subject
% -------------------------------------------------------------------------

%% Main
% paths and files
details = compi_get_subject_details(id, options);

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('model', 'mmn', id, '');

% check destination folder
if ~exist(details.dirs.results_behav, 'dir')
    mkdir(details.dirs.results_behav);
end
cd(details.dirs.results_behav);

try
    % check for previous preprocessing
    load(fullfile(details.dirs.preproc, 'design.mat'));
    disp(['Subject ' id ' has been modeled before.']);
    if options.eeg.model.overwrite
        clear design;
        disp('Overwriting...');
        error('Continue to modeling step.');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Modeling subject ' id ' ...']);
    
    %-- simulate beliefs -------------------------------------------------%
    % NOTE: all COMPI subjects received same tone sequence
    tones = getfield(load(fullfile(options.roots.config,  'tones.mat')), 'tones');
  
    design = compi_volatilityMMN_extract_beliefs_eHGF(tones);
    
    savefig(fullfile(details.dirs.preproc, ['COMPI_' id '_regressor_traj']));
    close;

    %-- modify design file -----------------------------------------------%
    % INSERT SPECIAL CASE SUBJECTS HERE

    save(fullfile(details.dirs.preproc, ['design.mat']),'design','-mat');

    
    fprintf('\nDesign file has been created.\n\n');
    
    fprintf('\nModeling done: subject %s', id);
    disp('   ');
    disp('*----------------------------------------------------*');
    disp('   ');
    
end

cd(options.roots.results);
close all

diary OFF
end