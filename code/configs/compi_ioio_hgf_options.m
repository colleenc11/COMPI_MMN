function [options] = compi_ioio_hgf_options(options, ms)
% -------------------------------------------------------------------------
% Function that appends option structure with all options relevant to HGF
% analysis.
% -------------------------------------------------------------------------

%% Analysis options
% TODO: Could still implement analysis options here
% % Select analysis steps
% verbosity = 1;
% if verbosity > 1
%     options.hgf.pipe.executeStepsPerSubject = {
%         'inversion'
%         'plotting'
%         'behaviour'};
% else
%     options.hgf.pipe.executeStepsPerSubject = {
%         'behaviour'};
% end

% Select HGF model space
options.hgf.model_space = ms;
lt = options.behav.last_trial;

% Simulation options
%options.hgf.sim_noise = [0 1 2]; % (Additive) noise for confusion matrix
options.hgf.sim_noise = [0]; % (Additive) noise for confusion matrix

% Simulation seed (set to NaN if not seed should be used)
% Note: For estimating model performance only first seed will be used, the
% other seeds are used for the simulation pipeline (e.g. computing
% parameter recoveribility and confusion matrices (averaged across seeds)
%options.hgf.seeds = [10 11 12 13 14 15 16 17 18 19];
options.hgf.seeds = [10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29];
%options.hgf.seeds = NaN;


%% Return model space
switch options.hgf.model_space
    
    case 1
        %------------------------------------------------------------------
        % Model space 1: Model space that was identifiable in DMPAD data
        % set using no random seed.
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'tapas_6.0')));
        
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {'HGF','HGF BO', 'AR1', 'AR1 BO'};
        
        options.hgf.prc_models = {...
            'MS1_dmpad_hgf_config',...                                  % 1
            ['MS1_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS1_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS1_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS1_dmpad_constant_voltemp_exp_config',...      % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS1_dmpad_hgf_config & MS1_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS1_dmpad_hgf_BO_config & MS1_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS1_dmpad_hgf_ar1_lvl3_config & MS1_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS1_dmpad_hgf_ar1_lvl3_BO_config & MS1_dmpad_constant_voltemp_exp_config
            ];
        
        
    case 2
        %------------------------------------------------------------------
        % Model space 2: Comparing HGF versions 3 with eHGF
        %------------------------------------------------------------------
        options.hgf.models = 1:4;
        options.hgf.win_mod = 2;
        options.hgf.model_names = {'HGF3', 'eHGF', 'HGF6', 'AR1'};
        
        options.hgf.prc_models = {...
            'MS2_dmpad_hgf_v3_config',...                                  % 1
            'MS2_dmpad_ehgf_config',...                                    % 2
            'MS2_dmpad_hgf_v6_config',...                                  % 3
            'MS2_dmpad_hgf_v3_ar1_lvl3_config',...                         % 4
            };
        
        options.hgf.obs_models = {...
            'MS2_dmpad_constant_voltemp_exp_config',...      % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS2_dmpad_hgf_v3_config & MS2_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS2_dmpad_hgf_v6_config & MS2_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS2_dmpad_ehgf_config & MS2_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS2_dmpad_hgf_v3_ar1_lvl3_config & MS2_dmpad_constant_voltemp_exp_config
            ];
        
    case 3
        %------------------------------------------------------------------
        % Model space 3: Comparing HGF, Ar1 and eHGF (all version 6) with
        % default priors from current toolbox version across two response
        % models.
        % FIXME: some priors were changed inconsistently.
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:6;
        options.hgf.win_mod = 2;
        options.hgf.model_names = {'HGFn', 'eHGFn', 'AR1n',...
            'HGF', 'eHGF', 'AR1'};
        
        options.hgf.prc_models = {...
            'MS3_dmpad_hgf_config',...                                  % 1
            'MS3_dmpad_ehgf_config',...                                 % 2
            'MS3_dmpad_hgf_ar1_lvl3_config',...                         % 3
            };
        
        options.hgf.obs_models = {...
            'MS3_dmpad_unitsq_sgm_mu3_with_noise_config',...            % 1
            'MS3_dmpad_unitsq_sgm_mu3_config',...                       % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS3_dmpad_hgf_config & MS3_dmpad_unitsq_sgm_mu3_with_noise
            2     1    %  2: MS3_dmpad_ehgf_config & MS3_dmpad_unitsq_sgm_mu3_with_noise
            3     1    %  3: MS3_dmpad_hgf_ar1_lvl3_config & MS3_dmpad_unitsq_sgm_mu3_with_noise
            1     2    %  1: MS3_dmpad_hgf_config & MS3_dmpad_unitsq_sgm_mu3
            2     2    %  2: MS3_dmpad_ehgf_config & MS3_dmpad_unitsq_sgm_mu3
            3     2    %  3: MS3_dmpad_hgf_ar1_lvl3_config & MS3_dmpad_unitsq_sgm_mu3
            ];
        
    case 4
        %------------------------------------------------------------------
        % Model space 4: Still comparing HGF, Ar1 and eHGF (all version 6) with
        % default priors from current toolbox version across two response
        % models.
        % Unified priors and corrected config file for ar1 => mu0's were
        % still fixed as was kappa.
        % FIXME: eta was wrongly specified in response model without noise,
        % probably let to negative probabilities.
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:6;
        options.hgf.win_mod = 2;
        options.hgf.model_names = {'HGFn', 'eHGFn', 'AR1n',...
            'HGF', 'eHGF', 'AR1'};
        
        options.hgf.prc_models = {...
            'MS4_dmpad_hgf_config',...                                  % 1
            'MS4_dmpad_ehgf_config',...                                 % 2
            'MS4_dmpad_hgf_ar1_lvl3_config',...                         % 3
            };
        
        options.hgf.obs_models = {...
            'MS4_dmpad_unitsq_sgm_mu3_with_noise_config',...            % 1
            'MS4_dmpad_unitsq_sgm_mu3_config',...                       % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS4_dmpad_hgf_config & MS4_dmpad_unitsq_sgm_mu3_with_noise
            2     1    %  2: MS4_dmpad_ehgf_config & MS4_dmpad_unitsq_sgm_mu3_with_noise
            3     1    %  3: MS4_dmpad_hgf_ar1_lvl3_config & MS4_dmpad_unitsq_sgm_mu3_with_noise
            1     2    %  1: MS4_dmpad_hgf_config & MS4_dmpad_unitsq_sgm_mu3
            2     2    %  2: MS4_dmpad_ehgf_config & MS4_dmpad_unitsq_sgm_mu3
            3     2    %  3: MS4_dmpad_hgf_ar1_lvl3_config & MS4_dmpad_unitsq_sgm_mu3
            ];
        
    case 5
        %------------------------------------------------------------------
        % Model space 5: Trying to find sensible priors for ehgf. Starting
        % from default values of the toolbox (1) then freeing mu30 (2) and
        % then mu30 and sigma 30 (3).
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:6;
        options.hgf.win_mod = 2;
        options.hgf.model_names = {'eHGFn', 'mu30n', 'mu30sa30n',...
            'eHGF', 'mu30', 'mu30sa30'};
        
        options.hgf.prc_models = {...
            'MS5_dmpad_ehgf_config',...                                 % 1
            'MS5_dmpad_ehgf_mu30_free_config',...                       % 2
            'MS5_dmpad_ehgf_mu30_sa30_free_config',...                  % 3
            };
        
        options.hgf.obs_models = {...
            'MS5_dmpad_unitsq_sgm_mu3_with_noise_config',...            % 1
            'MS5_dmpad_unitsq_sgm_mu3_config',...                       % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS5_dmpad_ehgf_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            2     1    %  2: MS5_dmpad_ehgf_mu30_free_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            3     1    %  3: MS5_dmpad_ehgf_mu30_sa30_free_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            1     2    %  4: MS5_dmpad_ehgf_config & MS5_dmpad_unitsq_sgm_mu3
            2     2    %  5: MS5_dmpad_ehgf_mu30_free_config & MS5_dmpad_unitsq_sgm_mu3
            3     2    %  6: MS5_dmpad_ehgf_mu30_sa30_free_config & MS5_dmpad_unitsq_sgm_mu3
            ];
        
        options.hgf.families{1} = {[1:3], [4:6]};
        options.hgf.family_names{1} = {'noise', 'nonoise'};
        options.hgf.family_titles{1} = 'Response Model Comparison';
        
    case 6
        %------------------------------------------------------------------
        % Model space 6: TODO
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:6;
        options.hgf.win_mod = 5;
        options.hgf.model_names = {'eHGFn', 'mu30n', 'mu30sa30n',...
            'eHGF', 'mu30', 'mu30sa30'};
        
        options.hgf.prc_models = {...
            'MS6_dmpad_ehgf_config',...                                 % 1
            'MS6_dmpad_ehgf_mu30_free_config',...                       % 2
            'MS6_dmpad_ehgf_mu30_sa30_free_config',...                  % 3
            };
        
        options.hgf.obs_models = {...
            'MS6_dmpad_unitsq_sgm_mu3_with_noise_config',...            % 1
            'MS6_dmpad_unitsq_sgm_mu3_config',...                       % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS5_dmpad_ehgf_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            2     1    %  2: MS5_dmpad_ehgf_mu30_free_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            3     1    %  3: MS5_dmpad_ehgf_mu30_sa30_free_config & MS5_dmpad_unitsq_sgm_mu3_with_noise
            1     2    %  1: MS5_dmpad_ehgf_config & MS5_dmpad_unitsq_sgm_mu3
            2     2    %  2: MS5_dmpad_ehgf_mu30_free_config & MS5_dmpad_unitsq_sgm_mu3
            3     2    %  3: MS5_dmpad_ehgf_mu30_sa30_free_config & MS5_dmpad_unitsq_sgm_mu3
            ];
        
        
    case 7
        %------------------------------------------------------------------
        % Model space 7: Try to replicate simulations from MS1 after
        % passing random seed to *_sim function for observational model.
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'tapas_6.0')));
        
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {'HGF','HGF BO', 'AR1', 'AR1 BO'};
        
        options.hgf.prc_models = {...
            'MS1_dmpad_hgf_config',...                                  % 1
            ['MS1_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS1_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS1_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS1_dmpad_constant_voltemp_exp_config',...      % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS1_dmpad_hgf_config & MS1_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS1_dmpad_hgf_BO_config & MS1_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS1_dmpad_hgf_ar1_lvl3_config & MS1_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS1_dmpad_hgf_ar1_lvl3_BO_config & MS1_dmpad_constant_voltemp_exp_config
            ];
        
        
    case 8
        %------------------------------------------------------------------
        % Model space 8: Model space that was identifiable in DMPAD data
        % set using no random seed. Try to see how much C and
        % recoveribiluty varies, when seed is not set.
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'tapas_6.0')));
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'VBA')));
        
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {'HGF','HGF BO', 'AR1', 'AR1 BO'};
        
        options.hgf.prc_models = {...
            'MS1_dmpad_hgf_config',...                                  % 1
            ['MS1_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS1_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS1_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS1_dmpad_constant_voltemp_exp_config',...      % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS1_dmpad_hgf_config & MS1_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS1_dmpad_hgf_BO_config & MS1_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS1_dmpad_hgf_ar1_lvl3_config & MS1_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS1_dmpad_hgf_ar1_lvl3_BO_config & MS1_dmpad_constant_voltemp_exp_config
            ];
        
        
    case 9
        %------------------------------------------------------------------
        % Model space 9: Model space that was identifiable in DMPAD data
        % with multiple random seeds. Try to see how much C and
        % recoveribiluty varies, for different seeds.
        % Changes with respect to MS1:
        % => theta and sigma20 fixed.
        % => sigma30 set to 1 for both models (previously set to 4 for
        % vanilla hgf, but to 1 for AR1)
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
        
        options.hgf.models = 1:4;
        %options.hgf.win_mod = 3;
        options.hgf.win_mod_eeg = 3;
        options.hgf.model_names = {'HI','CI', 'HII', 'CII'};
        
        options.hgf.prc_models = {...
            'MS9_dmpad_hgf_config',...                                  % 1
            ['MS9_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS9_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS9_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS9_dmpad_constant_voltemp_exp_config',...                 % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS9_dmpad_hgf_config & MS9_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS9_dmpad_hgf_BO_config & MS9_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS9_dmpad_hgf_ar1_lvl3_config & MS9_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS9_dmpad_hgf_ar1_lvl3_BO_config & MS9_dmpad_constant_voltemp_exp_config
            ];
        
        
    case 10
        %------------------------------------------------------------------
        % Model space 10: Comparing eHGF to eHGF with ar1 process at third
        % level. Using default prior from HGF version 6.
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {...
            'eHGF', 'eHGFBO', 'eAR1', 'eAR1BO',...
            'eHGFn', 'eHGFBOn', 'eAR1n', 'eAR1BOn'};
        
        options.hgf.prc_models = {...
            'MS10_dmpad_ehgf_config',...                                % 1
            ['MS10_dmpad_ehgf_BO_lt' num2str(lt) '_config'],...         % 2
            'MS10_dmpad_ehgf_ar1_config',...                            % 3
            ['MS10_dmpad_ehgf_ar1_BO_lt' num2str(lt) '_config']         % 4
            };
        
        options.hgf.obs_models = {...
            'MS10_dmpad_unitsq_sgm_mu3_config',...                      % 1
            'MS10_dmpad_unitsq_sgm_mu3_with_noise_config',...           % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS10_dmpad_ehgf_config & MS10_dmpad_unitsq_sgm_mu3_config
            2     1    %  2: MS10_dmpad_ehgf_BO & MS10_dmpad_unitsq_sgm_mu3_config
            3     1    %  3: MS10_dmpad_ehgf_ar1_config & MS10_dmpad_unitsq_sgm_mu3_config
            4     1    %  4: MS10_dmpad_ehgf_ar1_BO & MS10_dmpad_unitsq_sgm_mu3_config
            1     2    %  1: MS10_dmpad_ehgf_config & MS10_dmpad_unitsq_sgm_mu3_with_noise_config
            2     2    %  2: MS10_dmpad_ehgf_BO & MS10_dmpad_unitsq_sgm_mu3_with_noise_config
            3     2    %  3: MS10_dmpad_ehgf_ar1_config & MS10_dmpad_unitsq_sgm_mu3_with_noise_config
            4     2    %  4: MS10_dmpad_ehgf_ar1_BO & MS10_dmpad_unitsq_sgm_mu3_with_noise_config
            ];
        
    case 11
        %------------------------------------------------------------------
        % Model space 11: Comparing eHGF to eHGF with ar1 process at third
        % level. 
        % Changed from MS10: Reduced variance for om2 (4 => 2) and changed
        % mean for om3 (2 => -2) to get rid of spikes for subject 0116 and 
        % 0060.
        % Evaluation: Introduced many spikes in regular eHGF, which is now
        % also the winning model.
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {...
            'eHGF', 'eHGFBO', 'eAR1', 'eAR1BO',...
            'eHGFn', 'eHGFBOn', 'eAR1n', 'eAR1BOn'};
        
        options.hgf.prc_models = {...
            'MS11_dmpad_ehgf_config',...                                % 1
            ['MS11_dmpad_ehgf_BO_lt' num2str(lt) '_config'],...         % 2
            'MS11_dmpad_ehgf_ar1_config',...                            % 3
            ['MS11_dmpad_ehgf_ar1_BO_lt' num2str(lt) '_config']         % 4
            };
        
        options.hgf.obs_models = {...
            'MS11_dmpad_unitsq_sgm_mu3_config',...                      % 1
            'MS11_dmpad_unitsq_sgm_mu3_with_noise_config',...           % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS11_dmpad_ehgf_config & MS11_dmpad_unitsq_sgm_mu3_config
            2     1    %  2: MS11_dmpad_ehgf_BO & MS11_dmpad_unitsq_sgm_mu3_config
            3     1    %  3: MS11_dmpad_ehgf_ar1_config & MS11_dmpad_unitsq_sgm_mu3_config
            4     1    %  4: MS11_dmpad_ehgf_ar1_BO & MS11_dmpad_unitsq_sgm_mu3_config
            1     2    %  1: MS11_dmpad_ehgf_config & MS11_dmpad_unitsq_sgm_mu3_with_noise_config
            2     2    %  2: MS11_dmpad_ehgf_BO & MS11_dmpad_unitsq_sgm_mu3_with_noise_config
            3     2    %  3: MS11_dmpad_ehgf_ar1_config & MS11_dmpad_unitsq_sgm_mu3_with_noise_config
            4     2    %  4: MS11_dmpad_ehgf_ar1_BO & MS11_dmpad_unitsq_sgm_mu3_with_noise_config
            ];
        
        case 12
        %------------------------------------------------------------------
        % Model space 12: Comparing eHGF to eHGF with ar1 process at third
        % level. Using default toolbox priors (only freed mu30). 
        % Changed from MS10: Estimate mu30
        % Evaluation: Model 1 wins, two subjects show spikes, for AR1 model
        % no trajectory shows spikes.
        %------------------------------------------------------------------
        rmpath(genpath(fullfile(options.roots.code, 'Toolboxes', 'HGF_3.0')));
        options.hgf.models = 1:4;
        options.hgf.win_mod = 1;
        options.hgf.model_names = {...
            'eHGF', 'eHGFBO', 'eAR1', 'eAR1BO',...
            'eHGFn', 'eHGFBOn', 'eAR1n', 'eAR1BOn'};
        
        options.hgf.prc_models = {...
            'MS12_dmpad_ehgf_config',...                                % 1
            ['MS12_dmpad_ehgf_BO_lt' num2str(lt) '_config'],...         % 2
            'MS12_dmpad_ehgf_ar1_config',...                            % 3
            ['MS12_dmpad_ehgf_ar1_BO_lt' num2str(lt) '_config']         % 4
            };
        
        options.hgf.obs_models = {...
            'MS12_dmpad_unitsq_sgm_mu3_config',...                      % 1
            'MS12_dmpad_unitsq_sgm_mu3_with_noise_config',...           % 2
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS12_dmpad_ehgf_config & MS12_dmpad_unitsq_sgm_mu3_config
            2     1    %  2: MS12_dmpad_ehgf_BO & MS12_dmpad_unitsq_sgm_mu3_config
            3     1    %  3: MS12_dmpad_ehgf_ar1_config & MS12_dmpad_unitsq_sgm_mu3_config
            4     1    %  4: MS12_dmpad_ehgf_ar1_BO & MS12_dmpad_unitsq_sgm_mu3_config
            1     2    %  1: MS12_dmpad_ehgf_config & MS12_dmpad_unitsq_sgm_mu3_with_noise_config
            2     2    %  2: MS12_dmpad_ehgf_BO & MS12_dmpad_unitsq_sgm_mu3_with_noise_config
            3     2    %  3: MS12_dmpad_ehgf_ar1_config & MS12_dmpad_unitsq_sgm_mu3_with_noise_config
            4     2    %  4: MS12_dmpad_ehgf_ar1_BO & MS12_dmpad_unitsq_sgm_mu3_with_noise_config
            ];
        
       case 13
        %------------------------------------------------------------------
        % Model space 9: Model space that was identifiable in DMPAD data
        % with multiple random seeds. Try to see how much C and
        % recoveribiluty varies, for different seeds.
        % Changes with respect to MS1:
        % => theta and sigma20 fixed.
        % => sigma30 set to 1 for both models (previously set to 4 for
        % vanilla hgf, but to 1 for AR1)
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
        
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {'HGF','HGF BO', 'AR1', 'AR1 BO'};
        
        options.hgf.prc_models = {...
            'MS9_dmpad_hgf_config',...                                  % 1
            ['MS9_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS9_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS9_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS9_dmpad_constant_voltemp_exp_config',...                 % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS9_dmpad_hgf_config & MS9_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS9_dmpad_hgf_BO_config & MS9_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS9_dmpad_hgf_ar1_lvl3_config & MS9_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS9_dmpad_hgf_ar1_lvl3_BO_config & MS9_dmpad_constant_voltemp_exp_config
            ];
        
        
        case 14
        %------------------------------------------------------------------
        % Model space 14: Model space that was identifiable in DMPAD data
        % with multiple random seeds. Try to see how much C and
        % recoveribiluty varies, for different seeds.
        % Changes with respect to MS1:
        % => theta and sigma20 fixed.
        % => sigma30 set to 1 for both models (previously set to 4 for
        % vanilla hgf, but to 1 for AR1)
        % Changes with respect to MS9:
        % => kappa prior on variance set to 0.5 instead of 1 to avoid
        % spikes in CHR 0070
        %------------------------------------------------------------------
        % Make sure, that we use the correct HGF version (3.0)
        addpath(genpath(fullfile(options.roots.toolboxes, 'HGF_3.0')));
        
        options.hgf.models = 1:4;
        options.hgf.win_mod = 3;
        options.hgf.model_names = {'HGF','HGF BO', 'Drift', 'Drift BO'};
        
        options.hgf.prc_models = {...
            'MS14_dmpad_hgf_config',...                                  % 1
            ['MS14_dmpad_hgf_BO_lt' num2str(lt) '_config'],...           % 2
            'MS14_dmpad_hgf_ar1_lvl3_config',...                         % 3
            ['MS14_dmpad_hgf_ar1_lvl3_BO_lt' num2str(lt) '_config'],...  % 4
            };
        
        options.hgf.obs_models = {...
            'MS14_dmpad_constant_voltemp_exp_config',...                 % 1
            };
        
        options.hgf.combinations = [...
            1     1    %  1: MS14_dmpad_hgf_config & MS14_dmpad_constant_voltemp_exp_config
            2     1    %  2: MS14_dmpad_hgf_BO_config & MS14_dmpad_constant_voltemp_exp_config
            3     1    %  3: MS14_dmpad_hgf_ar1_lvl3_config & MS14_dmpad_constant_voltemp_exp_config
            4     1    %  4: MS14_dmpad_hgf_ar1_lvl3_BO_config & MS14_dmpad_constant_voltemp_exp_config
            ];
        
end

%% Create Results folder
% HGF
options.roots.results_hgf = fullfile(options.roots.results,...
    'results_hgf',['ms' num2str(ms)]);
mkdir(options.roots.results_hgf);


%% Create diagnostic roots and folders
options.roots.diag_hgf = fullfile(options.roots.results,...
    'diag_hgf',['ms' num2str(ms)]);
mkdir(options.roots.diag_hgf);

for i_m = 1:length(options.hgf.models)
    mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'traj'));
    mkdir(fullfile(options.roots.diag_hgf,['m' num2str(i_m)],'corr'));
end
mkdir(fullfile(options.roots.diag_hgf, 'C'));

% TODO: Check which options are needed (see below) and integrate them in function.


% options.model.winningPerceptual = 'tapas_hgf_binary';
% options.model.winningResponse   = 'tapas_ioio_unitsq_sgm_mu3';
%
% options.model.all               = {'HGF','HGF_v1','AR1','HGF_2Levels','Sutton','RW'};
% options.model.typeModel         = char(ModelName);
% options.errorfile               = [options.model.typeModel,'.mat'];
% options.model.modelling_bias    = false;
%
% %% Model Space
% switch options.model.typeModel
%     case 'HGF'
%         options.model.perceptualModels   = 'tapas_hgf_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm_mu3', 'tapas_ioio_cue_unitsq_sgm_mu3',...
%             'tapas_ioio_advice_unitsq_sgm_mu3'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','mu2_0'};
%     case 'HGF_v1'
%         options.model.perceptualModels   = 'tapas_hgf_binary_v1';
%         options.model.responseModels   = ...
%             {'ioio_constant_voltemp_exp','ioio_constant_voltemp_exp_cue',...
%             'ioio_constant_voltemp_exp_adv'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','mu2_0'};
%     case 'AR1'
%         options.model.perceptualModels   = 'tapas_hgf_ar1_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%         options.model.simulationsParameterArray = {'ka','om','th','ze','m2'};
%     case 'HGF_2Levels'
%         options.model.perceptualModels   = 'tapas_hgf_binary_novol';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%     case 'Sutton'
%         options.model.perceptualModels   = 'tapas_sutton_k1_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
%     case 'RW'
%         options.model.perceptualModels   = 'tapas_rw_binary';
%         options.model.responseModels   = ...
%             {'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%             'tapas_ioio_advice_unitsq_sgm'};
% end
%
% options.model.allresponseModels = ...
%     {'tapas_ioio_unitsq_sgm_mu3','tapas_ioio_cue_unitsq_sgm_mu3',...
%     'tapas_ioio_advice_unitsq_sgm_mu3',...
%     'tapas_ioio_unitsq_sgm','tapas_ioio_cue_unitsq_sgm',...
%     'tapas_ioio_advice_unitsq_sgm'};
% options.model.labels = ...
%     {'HGF_Both', 'Cue','HGF_Advice','AR1_Both','Cue',...
%     'AR1_Advice','RW_Both','Cue','RW_Advice'};
% options.family.perceptual.labels = {'HGF','AR1','RW'};
% options.family.perceptual.partition = [1 1 1 2 2 2 3 3 3];
%
% options.family.responsemodels1.labels = {'Both','Cue','Advice'};
% options.family.responsemodels1.partition = [1 2 3 1 2 3 1 2 3];



% %% Model Parameters
% options.model.hgf   = {'mu2_0','mu3_0','kappa','omega_2','omega_3'};
% options.model.rw    = {'mu2_0','alpha'};
% options.model.ar1   = {'m3','phi3','kappa','omega_2','omega_3'};
%
% options.model.sgm   = {'zeta_1','zeta_2'};
% options.model.bias  = {'zeta_1','zeta_2','psi'};
