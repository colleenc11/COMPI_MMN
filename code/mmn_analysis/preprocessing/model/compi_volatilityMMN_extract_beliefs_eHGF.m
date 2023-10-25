function [regressors, bopars] = compi_volatilityMMN_extract_beliefs_eHGF(inputValues)
% -------------------------------------------------------------------------
% COMPI_VOLATILITYMMN_EXTRACT_BELIEFS_EHGF Applies bayesian learning model 
% to input values (tones) and creates regressors from behavioral model.
%   IN:     inputValues     tone sequence
%   OUT:    regressors      trajectories of model output   
%           bopars          structure of all model information
% -------------------------------------------------------------------------

%% Main

% fit model to input tones
u = inputValues';
bopars = tapas_fitModel([],...
    u,...
    'tapas_ehgf_binary_config',...
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');

% plot trajectories
tapas_hgf_binary_plotTraj(bopars);

%% Create regressor file

% precision-weighted prediction errors
regressors.epsilon2            = abs(bopars.traj.epsi(:,2));
regressors.epsilon3            = bopars.traj.epsi(:,3);

% prediction errors
regressors.delta1              = abs(bopars.traj.da(:,1));
regressors.delta2              = bopars.traj.da(:,2);
regressors.delta3              = bopars.traj.da(:,3);

% precision ratio
regressors.psi2                 = bopars.traj.psi(:,2);
regressors.psi3                 = bopars.traj.psi(:,3);


end