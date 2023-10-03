function compi_plot_covar_vs_source_amplitude(tPeak, sourceToFind, covar, factor, options)
%--------------------------------------------------------------------------
% COMPI_PLOT_COVAR_VS_SOURCE_AMPLITUDE Plot peak source amplitude values 
% from time point and source against covariate of interest
%
%   IN:     tPeak           peak time point to plot
%           sourceToFind    name of source to plot as string
%           covar           covariate of interest
%           factor          name of factor to plot as string
%           options         as set by compi_mmn_options();
%
%   OUT:     
%--------------------------------------------------------------------------

%% Specify parameters

% calculate time window for plotting
time_resolution = 1000 / options.eeg.preproc.downsamplefreq; % in milliseconds
epochwin        = options.eeg.preproc.epochwin;
tWindow         = epochwin(1):time_resolution:epochwin(2);

% Find the index corresponding to peak time point
[~, idxTimePoint] = min(abs(tWindow - tPeak));

% Find the index of the specified label in the sourceArray
sourceArray = options.eeg.source.labels;
idxSource = find(strcmp(sourceArray, sourceToFind));

% Get covariate
covar_table = compi_get_covariates({covar}, ...
                        options.subjects.IDs{1}, options, 0);
gfScores = covar_table.(covar{1});

%% Extract source data
nContrasts = numel(sourceArray);

% Get data
for i_group = 1:numel(options.subjects.group_labels)
    if strcmp(options.subjects.group_labels{i_group}, options.condition)
        
        nSubjects = numel(options.subjects.IDs{i_group});
        erpWave = cell(nSubjects, nContrasts);
        
        for iSubject = 1:nSubjects
            id = char(options.subjects.IDs{i_group}(iSubject));
            details = compi_get_subject_details(id, options);

            % load source waveform data
            if startsWith(factor, 'oddball')
                data = spm_eeg_load(fullfile(details.eeg.erp.root, factor, ['B_diff_' factor '.mat']));
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.avg(iContrast,:));
                end
            elseif startsWith(factor, 'delta1')
                data = spm_eeg_load(fullfile(details.eeg.erp.root, factor, ['B_diff_' factor '.mat']));
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.avg(iContrast,:));
                end
            else
                data = spm_eeg_load([details.eeg.source.savefilename]);
                T = data.fttimelock;
                for iContrast = 1:nContrasts
                    erpWave{iSubject, iContrast} = squeeze(T.trial(:,iContrast,:));
                end
            end
        end
    end
end

% Extract data at time point and source
dataTimePoint = zeros(nSubjects, 1);
for subj = 1:nSubjects
    dataTimePoint(subj) = erpWave{subj, idxSource}(idxTimePoint); % muV
end


%% Plot the peak values
figure;
set(gcf,'position',[500,500,400,300])
scatter(dataTimePoint, gfScores, 'filled', 'k', 'SizeData', 70);
ylim([5 10])
% xlim([-0.5 0.5])
% title([sourceToFind ' Amplitude at ' num2str(tPeak) ' vs. GF Social']);

% Increase the size of the text on the axes
ax = gca; % Get the current axes
ax.FontSize = 34; % Set the font size for the axes

% Fit a linear regression model to the data
p = polyfit(dataTimePoint, gfScores, 1);

% Add the regression line to the plot
hline = refline(p);
hline.Color = 'k';
hline.LineWidth = 1.5;

[~, pValue] = corr(dataTimePoint, gfScores');
disp(pValue);

imageFile = fullfile(options.roots.results_source, options.condition, 'figures',...
        [sourceToFind '_amp_' num2str(tPeak) '_' covar{1} '_' factor]);

saveas(gcf, imageFile, 'fig');
saveas(gcf, imageFile, 'png');


