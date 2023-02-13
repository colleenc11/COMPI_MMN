function plot_phase_regressors (options)
% -------------------------------------------------------------------------
% DESCRIPTION
% -------------------------------------------------------------------------


% Collect regressor
% options.subjects.all = {...
%     '0101','0102','0103','0104','0106','0107','0109',...
%     '0110','0111','0114','0116','0120','0121','0123','0127',...
%     '0130','0131','0132','0137','0139_2','0141','0142'};

for i_sub = 1:length(options.subjects.all)
    id = options.subjects.all{i_sub};

    details = compi_get_subject_details(id, options);
    fileModel  = details.files.win_mod_eeg;
    load(fileModel);

    fileDesignMatrix = fullfile(details.dirs.preproc, 'design.mat');
    factors(i_sub).design = getfield(load(fileDesignMatrix), 'design');

    factors(i_sub).design.  sigma2   = (est.traj.muhat(:,1).*(1-est.traj.muhat(:,1)).*est.traj.sahat(:,2));

    factors(i_sub).design.  piHat2   = 1./(est.traj.muhat(:,1).*(1 -est.traj.muhat(:,1)).*est.traj.sahat(:,2));

    factors(i_sub).design.  omega2   = est.traj.w(:, 2);

    om2(i_sub) = est.p_prc.om(2);


end

% Break into phase
reg = fields(factors(1).design);
for i_fac = 1:length(fields(factors(1).design))
    for i_sub = 1:length(options.subjects.all)

        param = reg{i_fac};
    
        stable1.(param)(i_sub) = mean(factors(i_sub).design.(param)(1:34));
        volatile.(param)(i_sub) = mean(factors(i_sub).design.(param)(35:136));
        stable2.(param)(i_sub) = mean(factors(i_sub).design.(param)(137:end));
    
    end
end

% Plot phases
for i_fac = 1:length(fields(factors(1).design))

    param = reg{i_fac};

    figure;
    boxplot([stable1.(param); volatile.(param); stable2.(param)]','Notch','on','Labels',...
        {'Stable Phase 1','Volatile Phase','Stable Phase 2'});
    hold on
    x = repmat(1:3,length(stable1.(param)),1);  % create the x data needed to overlay the swarmchart on the boxchart
    scatter(x,[stable1.(param); volatile.(param); stable2.(param)]',"filled",'r','jitter','on','JitterAmount',0.05);
    
    title(['Average ' param ' by Task Phase']);

    if ~exist(fullfile(options.roots.diag_eeg, 'stat_ERPs'), 'dir')
        mkdir(fullfile(options.roots.diag_eeg, 'stat_ERPs'));
    end
    saveas(gcf, fullfile(options.roots.diag_eeg, 'stat_ERPs', param), 'fig');
    saveas(gcf, fullfile(options.roots.diag_eeg, 'stat_ERPs', param), 'png');
    fprintf('\nSaved an ERP plot for paramater %s\n\n', param);

    close all

end

% Plot omega2
log_subs = [5,8,12,13,15,17,18,21,23,24,25,27,28,32,33,34,35,37,39,42];

figure;
x = repmat(1:3,length(stable1.omega2),1);
scatter(x,[stable1.omega2; volatile.omega2; stable2.omega2]',"filled", 'b');
hold on

for i_sub = log_subs
    scatter(1, stable1.omega2(i_sub),'r', 'filled');
    scatter(2, volatile.omega2(i_sub),'r', 'filled');
    scatter(3, stable2.omega2(i_sub),'r', 'filled');
end

hold off

xlim([0 4])
xticks([0 1 2 3 4])
xticklabels({'', 'Stable1','Volatile','Stable2', ''})
ylabel({'omega2'})
title({'Average Omega2 by Task Phase'})

if ~exist(fullfile(options.roots.diag_eeg, 'stat_ERPs'), 'dir')
    mkdir(fullfile(options.roots.diag_eeg, 'stat_ERPs'));
end

saveas(gcf, fullfile(options.roots.diag_eeg, 'stat_ERPs', 'omega2'), 'fig');
saveas(gcf, fullfile(options.roots.diag_eeg, 'stat_ERPs', 'omega2'), 'png');
fprintf('\nSaved an ERP plot for paramater %s\n\n', 'omega2');

%% ANOVA

% [p,tbl,stats] = anova1([stable1', volatile', stable2']);
% 
% [h,p] = ttest(stable1', volatile');
% [h,p] = ttest(volatile', stable2');
% [h,p] = ttest(stable1', stable2');



end