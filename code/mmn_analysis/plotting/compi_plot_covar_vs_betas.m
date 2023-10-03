function compi_plot_covar_vs_betas(covariate, mask, options)


factorName = options.eeg.stats.regressors{1};
betaAll    = {};

for idCell = options.subjects.all
    id = char(idCell);

    details = compi_get_subject_details(id, options);

    switch factorName
        case {'oddball'}
            imgFile = fullfile(details.eeg.erp.root, factorName, ...
                'sensor_diff_oddball', 'smoothed_condition_mmn.nii');
        case {'oddball_stable'}
            imgFile = fullfile(details.eeg.erp.root, 'oddball_phases', ...
                'sensor_diff_stable_oddball_phases', 'smoothed_condition_mmn.nii');
        case {'oddball_volatile'}
            imgFile = fullfile(details.eeg.erp.root, 'oddball_phases', ...
                'sensor_diff_volatile_oddball_phases', 'smoothed_condition_mmn.nii');
    end

    beta = spm_summarise(imgFile, mask);

    betaAll = [betaAll; {beta}];

end

covars = compi_get_covariates({covariate}, ...
                        options.subjects.IDs{1}, options);

% Extract GF scores
gfScores = covars.(covariate{1});

% Compute the mean of each cell in betaAll
betaMeans = cellfun(@mean, betaAll);

% Create scatter plot with solid black dots
figure;
set(gcf,'position',[500,500,400,300])
scatter(betaMeans, gfScores, 'filled', 'k', 'SizeData', 70);
% xlabel('Mean Beta Value', 'FontSize', 14);
% ylabel('GF Social', 'FontSize', 14);
ylim([5,10])
set(gca, 'FontSize', 30)
% xlim([-1.5,2])
%title('Scatter plot of Mean Beta Value vs. GF Social');

% Fit a linear regression model to the data
p = polyfit(betaMeans, gfScores, 1);

% Add the regression line to the plot
hline = refline(p);
hline.Color = 'k';
hline.LineWidth = 1.5;



% % Calculate the Pearson correlation
% [r, pValue] = corr(betaMeans, gfScores');
% 
% % Display the correlation coefficient at the bottom right of the plot
% text(1.5, 6, sprintf('r = %.2f, p = %.3f', r, pValue), ...
%     'VerticalAlignment', 'bottom', ...
%     'HorizontalAlignment', 'right');

saveas(gca, fullfile(options.roots.paper_fig, [factorName '_beta_vs_' covariate{1}]), 'fig');
saveas(gca, fullfile(options.roots.paper_fig, [factorName '_beta_vs_' covariate{1}]), 'jpg');
