function compi_plot_covar_vs_source_betas(tPoint, factor, sourceToFind, covariate, options)
% -------------------------------------------------------------------------
% COMPI_PLOT_COVAR_VS_SOURCE_BETAS Plot first-level source betas against a
% covariate of interest.
%
%   IN:     tPoint          Peak time point in milliseconds (integer)
%           factor          Name of factor to plot (string)
%           sourceToFind    Name of source to plot (string)
%           covariate       The covariate of interest (cell)
%           options         Options structure as set by compi_mmn_options()
% -------------------------------------------------------------------------

%% Covert given time point into corresponding voxel index along x-axis

% calculate the fractional time point
% note, epoch begins 100 PST so we so we subtract this offset from the input time point
epochwin        = options.eeg.stats.firstLevelAnalysisWindow;         % epoch duration
tPeak           = tPoint-epochwin(1);                                 % adjusted peak time point
tFraction       = tPeak / (epochwin(2)-epochwin(1));                  % fractional time point within epoch

% calculate the fractional voxel index
nVoxels         = 77;                                   % total number of voxels
voxel_fraction  = tFraction * (nVoxels - 1);            % fractional voxel index
voxel_index     = round(voxel_fraction);                % round to nearest int

% Display the results
fprintf('Time Point (ms): %d\n', tPoint);
fprintf('Voxel Index: %d\n', voxel_index);


%% Loop through subjects and collect beta values

betaAll    = [];
for idCell = options.subjects.all
    id = char(idCell);

    details = compi_get_subject_details(id, options);           % subject-specific details

    % determine the image file path based on the factorName
    switch factor
        case {'oddball', 'oddball_stable', 'oddball_volatile'}
            imgFile = fullfile(details.eeg.erp.source.pathStats, ...
                ['source_' sourceToFind '_' factor], ...
                    'smoothed_condition_diff.nii,1');
        case 'delta1'
            imgFile = fullfile(details.eeg.firstLevel.source.pathStats, ...
                'lowPE', sourceToFind, ['beta_0002.nii']);
        case 'delta2'
            imgFile = fullfile(details.eeg.firstLevel.source.pathStats, ...
                'highPE', sourceToFind, ['beta_0002.nii']);
        case 'psi3'
            imgFile = fullfile(details.eeg.firstLevel.source.pathStats, ...
                'highPE', sourceToFind, ['beta_0003.nii']);
    end

    % load in image and extract data
    V = spm_vol(imgFile);
    imgData = spm_read_vols(V);

    % check if voxel_index is within valid range
    if voxel_index >= 1 && voxel_index <= size(imgData, 1)
        betaVal = imgData(voxel_index, 1, 1);                   % extract beta value
    else
        fprintf('Error: Voxel index is out of bounds.\n');
    end

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
xlim([-0.2,0.2])
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
saveas(gca, fullfile(options.roots.paper_fig, [factor '_sourceBeta_vs_' covariate{1}]), 'fig');
saveas(gca, fullfile(options.roots.paper_fig, [factor '_sourceBeta_vs_' covariate{1}]), 'jpg');



