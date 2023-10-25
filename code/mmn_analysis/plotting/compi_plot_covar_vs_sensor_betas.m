function compi_plot_covar_vs_sensor_betas(covariate, mask, options)
% -------------------------------------------------------------------------
% COMPI_PLOT_COVAR_VS_SENSOR_BETAS Plot first-level sensor betas against a
% covariate of interest.
%
%   IN:     covariate   The covariate of interest (string)
%           mask        File path to mask image
%           options     Options structure as set by compi_mmn_options()
% -------------------------------------------------------------------------

%% Collect beta values for each subject

factorName = options.eeg.stats.regressors{1};   % name of regressor
betaAll    = {};                                % empty cell array to store beta values

% loop through subjects and collect beta values
for idCell = options.subjects.all
    id = char(idCell);

    details = compi_get_subject_details(id, options); % subject-specific details

    % determine the image file path based on the factorName
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

    % summarize beta values within the specified mask
    beta = spm_summarise(imgFile, mask);

    % append beta values to the betaAll cell array
    betaAll = [betaAll; {beta}];

end

%% Create scatter plot

% extract covariate values
covars = compi_get_covariates({covariate}, ...
                        options.subjects.IDs{1}, options);

gfScores = covars.(covariate{1});

% Compute the mean of each cell in betaAll
betaMeans = cellfun(@mean, betaAll);

% Create scatter plot with solid black dots
figure;
set(gcf,'position',[500,500,400,300])
scatter(betaMeans, gfScores, 'filled', 'k', 'SizeData', 70);
ylim([5,10])
set(gca, 'FontSize', 30)
% xlim([-1.5,2])
% xlabel('Mean Beta Value', 'FontSize', 14);
% ylabel('GF', 'FontSize', 14);
% title('Scatter plot of Mean Beta Value vs. GF');

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

% save the figure as both .fig and .jpg
saveas(gca, fullfile(options.roots.paper_fig, [factorName '_beta_vs_' covariate{1}]), 'fig');
saveas(gca, fullfile(options.roots.paper_fig, [factorName '_beta_vs_' covariate{1}]), 'jpg');
