function compi_plot_covar_vs_sensor_betas(peakCoord, factor, covariate, options)
% -------------------------------------------------------------------------
% COMPI_PLOT_COVAR_VS_SENSOR_BETAS Plot first-level source betas against a
% covariate of interest.
%
%   IN:     peakCoord       Peak coorinate in voxel space
%           factor          Name of factor to plot (string)
%           sourceToFind    Name of source to plot (string)
%           covariate       The covariate of interest (cell)
%           options         Options structure as set by compi_mmn_options()
% -------------------------------------------------------------------------


%% Loop through subjects and collect beta values

betaAll    = [];
for idCell = options.subjects.all
    id = char(idCell);

    % subject-specific details
    details = compi_get_subject_details(id, options);        

    % determine the image file path based on the factorName
    switch factor
        case {'oddball', 'oddball_stable', 'oddball_volatile'}
            imgFile = fullfile(details.eeg.erp.root, factor, ...
                ['sensor_diff_' factor], 'smoothed_condition_diff.nii');
    end

    % load in image and extract data
    V = spm_vol(imgFile);
    imgData = spm_read_vols(V);

    % Convert the subscript indices (3D coordinates) to a linear index 
    linearIndex = sub2ind(size(imgData), peakCoord(1), peakCoord(2), peakCoord(3));

    % Retrieve the value from imgData using the calculated linear index
    betaVal = imgData(linearIndex);

    % append beta value to the betaAll cell array
    betaAll = [betaAll; betaVal];

end


%% Create scatter plot

% get covariate
covars = compi_get_covariates({covariate}, ...
                        options.subjects.IDs{1}, options, 0);

gfScores = covars.(covariate{1});

% Create scatter plot with solid black dots
figure;
set(gcf,'position',[500,500,400,300])
scatter(betaAll, gfScores, 'filled', 'k', 'SizeData', 70);
ylim([5,10])
set(gca, 'FontSize', 30)
xlim([-3,3.5])
% xlabel('Beta Value', 'FontSize', 14);
% ylabel('GF', 'FontSize', 14);
% title('Scatter plot of Mean Beta Value vs. GF');

% Fit a linear regression model to the data
p = polyfit(betaAll, gfScores, 1);

% Add the regression line to the plot
hline = refline(p);
hline.Color = 'k';
hline.LineWidth = 1.5;

% % Calculate the Pearson correlation
% [r, pValue] = corr(betaAll, gfScores');
% 
% % Display the correlation coefficient at the bottom right of the plot
% text(1.5, 6, sprintf('r = %.2f, p = %.3f', r, pValue), ...
%     'VerticalAlignment', 'bottom', ...
%     'HorizontalAlignment', 'right');

% save the figure as both .fig and .jpg
saveas(gca, fullfile(options.roots.paper_fig, [factor '_sensorBeta_vs_' covariate{1}]), 'fig');
saveas(gca, fullfile(options.roots.paper_fig, [factor '_sensorBeta_vs_' covariate{1}]), 'jpg');



