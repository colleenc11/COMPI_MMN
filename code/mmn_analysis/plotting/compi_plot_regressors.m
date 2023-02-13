function fh = compi_plot_regressors(design, sub)
% Plots compi Regressors from HGF for design matrix
% 
% different options depending on design (and existing regressors, i.e.,
% field names) for plotting are used
%
% See also getDMPADRegressors


% compatibility for some different naming
if ~isfield(design, 'Precision3')
    design.Precision3 = 1./design.Sigma3;
end

if ~isfield(design, 'Precision2')
    design.Precision2 = 1./design.Sigma2;
end

%% Plot
fh = figure;

% Subplots
subplot(6,1,1);
plot(design.Precision3([1:170],:), 'm', 'LineWidth', 4);
hold all;
ylabel('\pi_3');
plot(ones(170,1).*mean(design.Precision3,1),'k','LineWidth', 1,'LineStyle','-.');
subplot(6,1,2);
plot(design.Delta2([1:170],:), 'r', 'LineWidth', 4);
ylabel('\delta_2');
hold on;
plot(ones(170,1).*0,'k','LineWidth', 1,'LineStyle','-.');
subplot(6,1,3);
plot(design.Precision2([1:170],:), 'c', 'LineWidth', 4);
ylabel('\pi_2');
hold on;
plot(ones(170,1).*mean(design.Precision2,1),'k','LineWidth', 1,'LineStyle','-.');
subplot(6,1,4);
plot(design.OutcomePE([1:170],:), 'g', 'LineWidth', 4);
ylabel('\delta_o');
hold on;
plot(ones(170,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
subplot(6,1,5);
plot(design.SignedDelta1([1:170],:), 'b', 'LineWidth', 4);
ylabel('\delta_1');
hold on;
plot(ones(170,1).*0,'k','LineWidth', 1,'LineStyle','-.');
subplot(6,1,6);
plot(design.CuePE([1:170],:), 'y', 'LineWidth', 4);
ylabel('\delta_c');
ylim([0 1])
hold on;
plot(ones(170,1).*0.5,'k','LineWidth', 1,'LineStyle','-.');
xlabel('Trial number');
subplot(6,1,1);
hold on;
title([sprintf('HGF Regressor Trajectories %s', sub)], ...
    'FontWeight', 'bold');

end

