function design = compi_create_behav_regressors(id, options, doPlotFigure)
% Creates model-based GLM regressors for EEG design matrix from HGF fit
%
% Function adapted from dmpad_create_behav_regressors

if nargin < 3
    doPlotFigure = false;
end

details = compi_get_subject_details(id, options);


fileModel  = details.files.win_mod_eeg;

if exist(fileModel, 'file')
    load(fileModel); % winning model
else
    error(sprintf(...
        [' Behavioral model fit in (fileModel = %s) does not exist. \n '...
        ' Run dmpad_invert_behav_model for subject %s first'], ...
        fileModel, id));
end

%% Parameter calculations 
% see getDMPADRegressors

% cue              = behav_measures.cue{1};
% cue_new          = behav_measures.cue_advice_space{1};
input_u          = est.u;

cuePE            = abs(behav_measures.advice{1} - behav_measures.cue_advice_space{1});
cue_new          = behav_measures.cue_advice_space{1};

x=est.traj.muhat(:,1);
ze1=est.p_obs.ze1;
% ze1 = 0.5;
px = 1./(x.*(1-x));
pc = 1./(cue_new.*(1-cue_new));
wx = ze1.*px./(ze1.*px + pc);
wc = pc./(ze1.*px + pc);
b = wx.*x + wc.*cue_new;
outcomeP = ze1.*x + (1-ze1).*cue_new;

%% Create design file

design.CuePE        = cuePE;
design.SignedDelta1 = est.traj.da(:,1);
design.OutcomePE    = abs(input_u(:,1) - b);
design.Precision2   = 1./est.traj.sa(:,2);
design.Delta2       = est.traj.da(:,2);
design.Precision3   = 1./est.traj.sa(:,3);
design.Delta3       = abs(est.traj.mu(:,3) - est.traj.muhat(:,3));
design.Drift        = [1:170]';

% add in phase regressor
design.Phase = [(zeros(1,34)-1), zeros(1,102), ones(1,34)];

save(fullfile(details.dirs.preproc, ['design.mat']),'design','-mat');

%% Plot regressor trajectories

if doPlotFigure
    fh = compi_plot_regressors(design, id);
    saveas(fh, details.eeg.regressorfigure,'fig');
end
% close all

end

