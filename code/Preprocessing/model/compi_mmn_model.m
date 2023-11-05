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
  
    [design, bopars] = compi_volatilityMMN_extract_beliefs_eHGF(tones);
    
    save(fullfile(details.dirs.preproc, ['bopars.mat']),'bopars','-mat');
    savefig(fullfile(details.dirs.preproc, ['COMPI_' id '_regressor_traj']));
    close;

    %-- modify design file -----------------------------------------------%
    % add phase regressor to design matrix
    long_stable = zeros(1, 300);
    short_volatile = ones(1, 50);
    short_stable = zeros(1, 90);
    long_volatile = ones(1, 460);
    short_stable2 = zeros(1, 100);
    long_volatile2 = ones(1, 450);

    phase_reg = [long_stable, short_volatile, short_stable, long_volatile, ...
        long_stable, short_volatile, short_stable2, long_volatile2];

    design.phase = phase_reg';

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